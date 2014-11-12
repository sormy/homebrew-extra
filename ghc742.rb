require 'formula'

class Ghc742 < Formula
  homepage "http://haskell.org/ghc/"
  url "https://www.haskell.org/ghc/dist/7.4.2/ghc-7.4.2-src.tar.bz2"
  sha1 "73b3b39dc164069bc80b69f7f2963ca1814ddf3d"

  option "32-bit"
  option "tests", "Verify the build using the testsuite."

  depends_on "gmp"
  depends_on "gcc"
  
  if build.build_32_bit? || !MacOS.prefer_64_bit?
    resource "binary" do
      url "https://www.haskell.org/ghc/dist/7.4.2/ghc-7.4.2-i386-apple-darwin.tar.bz2"
      sha256 "80c946e6d66e46ca5d40755f3fbe3100e24c0f8036b850fd8767c4f9efd02bef"
    end
  else
    resource "binary" do
      url "https://www.haskell.org/ghc/dist/7.4.2/ghc-7.4.2-x86_64-apple-darwin.tar.bz2"
      sha1 "7c655701672f4b223980c3a1068a59b9fbd08825"
    end
  end

  def patches
    # Explained: http://hackage.haskell.org/trac/ghc/ticket/7040
    # Discussed: https://github.com/mxcl/homebrew/issues/13519
    "http://hackage.haskell.org/trac/ghc/raw-attachment/ticket/7040/ghc7040.patch"
  end

  resource "testsuite" do
    url "https://www.haskell.org/ghc/dist/7.4.2/ghc-7.4.2-testsuite.tar.bz2"
    sha1 "b5f38937872f7a10aaf89b11b0b417870d2cff7c"
  end

  fails_with :clang do
    cause <<-EOS.undent
      Building with Clang configures GHC to use Clang as its preprocessor,
      which causes subsequent GHC-based builds to fail.
    EOS
  end

  def install
    # Move the main tarball contents into a subdirectory
    (buildpath+"Ghcsource").install Dir["*"]

    resource("binary").stage do
      # Define where the subformula will temporarily install itself
      subprefix = buildpath+"subfo"

      # ensure configure does not use Xcode 5 "gcc" which is actually clang
      system "./configure", "--prefix=#{subprefix}", "--with-gcc=#{ENV.cc}"

      if MacOS.version <= :lion
        # __thread is not supported on Lion but configure enables it anyway.
        File.open("mk/config.h", "a") do |file|
          file.write("#undef CC_SUPPORTS_TLS")
        end
      end

      # -j1 fixes an intermittent race condition
      system "make", "-j1", "install"
      ENV.prepend_path "PATH", subprefix/"bin"
    end

    cd "Ghcsource" do
      # Fix an assertion when linking ghc with llvm-gcc
      # https://github.com/Homebrew/homebrew/issues/13650
      ENV["LD"] = "ld"

      if build.build_32_bit? || !MacOS.prefer_64_bit?
        ENV.m32 # Need to force this to fix build error on internal libgmp_ar.
        arch = "i386"
      else
        arch = "x86_64"
      end

      # These will find their way into ghc's settings file, ensuring
      # that ghc will look in the Homebrew lib dir for native libs
      # (e.g., libgmp) even if the prefix is not /usr/local. Both are
      # necessary to avoid problems on systems with custom prefixes:
      # ghci fails without the first, compiling packages that depend
      # on native libs fails without the second.
      ENV["CONF_CC_OPTS_STAGE2"] = "-B#{HOMEBREW_PREFIX}/lib"
      ENV["CONF_GCC_LINKER_OPTS_STAGE2"] = "-L#{HOMEBREW_PREFIX}/lib"
      
      inreplace "configure", "HaveDtrace=YES", "HaveDtrace=NO"

      # ensure configure does not use Xcode 5 "gcc" which is actually clang
      system "./configure", "--prefix=#{prefix}",
                            "--build=#{arch}-apple-darwin",
                            "--with-gcc=#{ENV.cc}"
      system "make"

      if build.include? "tests"
        resource("testsuite").stage do
          cd "testsuite" do
            (buildpath+"Ghcsource/config").install Dir["config/*"]
            (buildpath+"Ghcsource/driver").install Dir["driver/*"]
            (buildpath+"Ghcsource/mk").install Dir["mk/*"]
            (buildpath+"Ghcsource/tests").install Dir["tests/*"]
            (buildpath+"Ghcsource/timeout").install Dir["timeout/*"]
          end
          cd (buildpath+"Ghcsource/tests") do
            system "make", "CLEANUP=1", "THREADS=#{ENV.make_jobs}", "fast"
          end
        end
      end

      system "make"
      # -j1 fixes an intermittent race condition
      system "make", "-j1", "install"
      # use clang, even when gcc was used to build ghc
      settings = Dir[lib/"ghc-*/settings"][0]
      inreplace settings, "\"#{ENV.cc}\"", "\"clang\""
    end
  end

  test do
    hello = (testpath/"hello.hs")
    hello.write('main = putStrLn "Hello Homebrew"')
    output = `echo "main" | '#{bin}/ghci' #{hello}`
    assert $?.success?
    assert_match /Hello Homebrew/i, output
  end
end
