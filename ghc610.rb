require 'formula'

class Ghc610 < Formula
  homepage "http://haskell.org/ghc/"
  url "https://www.haskell.org/ghc/dist/6.10.4/ghc-6.10.4-src.tar.bz2"
  sha1 "0566858b409066d98da70de5adb9a7030d0df5dc"

  option "32-bit"
  option "tests", "Verify the build using the testsuite."

  depends_on "gmp4"
  depends_on "gcc"
  
  if build.build_32_bit? || !MacOS.prefer_64_bit?
    resource "binary" do
      url "https://www.haskell.org/ghc/dist/6.10.4/ghc-6.10.4-darwin-i386-snowleopard-bootstrap.tar.bz2"
      sha1 "bd6830318c522527b2c35a84724832d983054416"
     end
  else
    resource "binary" do
      url "https://www.haskell.org/ghc/dist/6.10.4/ghc-6.10.4-darwin-x86_64-snowleopard-macports-bootstrap.tar.bz2"
      sha1 "bd6830318c522527b2c35a84724832d983054416"
    end
  end

  def patches
    # Explained: http://hackage.haskell.org/trac/ghc/ticket/7040
    # Discussed: https://github.com/mxcl/homebrew/issues/13519
    "http://hackage.haskell.org/trac/ghc/raw-attachment/ticket/7040/ghc7040.patch"
    # https://www.haskell.org/pipermail/glasgow-haskell-users/2009-September/017765.html
    "file://" + File.dirname(__FILE__) + "/patches/ghc-6.10.2-osx.patch"
    # https://ghc.haskell.org/trac/ghc/ticket/5062
    #"https://ghc.haskell.org/trac/ghc/raw-attachment/ticket/5062/5062-3.patch"
  end

  fails_with :clang do
    cause <<-EOS.undent
      Building with Clang configures GHC to use Clang as its preprocessor,
      which causes subsequent GHC-based builds to fail.
    EOS
  end

  def install
    ohai "THIS BUILD PRODUCE UNUSABLE RESULT, NEED TO FIND PROBLEM AND FIX!"
    
    # Move the main tarball contents into a subdirectory
    (buildpath+"Ghcsource").install Dir["*"]

    resource("binary").stage "#{buildpath}/ghc-bin"
    
    ENV.prepend_path "PATH", "#{buildpath}/ghc-bin/bin"

    # replace hardcoded paths to temporary path in ghc wrapper
    inreplace "ghc-bin/bin/ghc", "/opt/local", "#{buildpath}/ghc-bin"
    # replace hardcoded paths to temporary path for packages
    inreplace "ghc-bin/lib/ghc-#{version}/package.conf", "/opt/local", "#{buildpath}/ghc-bin"

    # create missing ghc-pkg wrapper
    File.open("ghc-bin/bin/ghc-pkg", "w") do |file| 
      file.puts "#!/bin/sh\n"
      file.puts "exec #{buildpath}/ghc-bin/lib/ghc-#{version}/ghc-pkg --global-conf=#{buildpath}/ghc-bin/lib/ghc-#{version}/package.conf ${1+\"$@\"}\n"
    end
    FileUtils.chmod 0755, "ghc-bin/bin/ghc-pkg"

    # create missing hsc2hs wrapper
    File.open("ghc-bin/bin/hsc2hs", "w") do |file| 
      file.puts "#!/bin/sh\n"
      if !build.build_32_bit?
        file.puts "HSC2HS_EXTRA=\"--cflag=-m64 --cflag=-fno-stack-protector --lflag=-m64\"\n"
      end
      file.puts "exec #{buildpath}/ghc-bin/lib/ghc-#{version}/hsc2hs"\
                " --template=#{buildpath}/ghc-bin/lib/ghc-#{version}/hsc2hs-0.67/template-hsc.h"\
                " $HSC2HS_EXTRA"\
                " ${1+\"$@\"}\n"\
                " -I#{buildpath}/ghc-bin/lib/ghc-#{version}/include"
    end
    FileUtils.chmod 0755, "ghc-bin/bin/hsc2hs"

    # relocate deps to homebrew gmp's path
    system "install_name_tool -change /opt/local/lib/libgmp.3.dylib /usr/local/opt/gmp4/lib/libgmp.3.dylib ghc-bin/lib/ghc-#{version}/ghc"
    system "install_name_tool -change /opt/local/lib/libgmp.3.dylib /usr/local/opt/gmp4/lib/libgmp.3.dylib ghc-bin/lib/ghc-#{version}/ghc-pkg"
    system "install_name_tool -change /opt/local/lib/libgmp.3.dylib /usr/local/opt/gmp4/lib/libgmp.3.dylib ghc-bin/lib/ghc-#{version}/hsc2hs"

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
      
      # ensure configure does not use Xcode 5 "gcc" which is actually clang
      system "./configure", "--prefix=#{prefix}",
                            "--build=#{arch}-apple-darwin",
                            "--with-gcc=#{ENV.cc}"
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
