require 'formula'

class Ghc610bin < Formula
  homepage "http://haskell.org/ghc/"
  url "https://www.haskell.org/ghc/dist/6.10.4/GHC-6.10.4-i386.pkg"
  sha1 "849d2bb2108de6f830e2d99f410734f5502b13d1"
  version "6.10.4"

  def install
    system "cd ghc.pkg && cat Payload | gunzip -dc | cpio -i"

    file_names = ["bin/ghc-6.10.4", "bin/ghc-pkg-6.10.4", "bin/ghci-6.10.4", "bin/haddock", "bin/hsc2hs", "bin/runghc", "lib/ghc-6.10.4/package.conf"]
    file_names.each do |file_name|
      file_path = "#{buildpath}/ghc.pkg/GHC.framework/Versions/610/usr/#{file_name}"
      text = File.read(file_path)
      new_contents = text.gsub(/\/Library\/Frameworks\/GHC\.framework\/Versions\/610\/usr\//, "#{prefix}/")
      ohai "Patching file: #{file_name}"
      File.open(file_path, "w") {|file| file.puts new_contents }
    end

    (prefix).install "ghc.pkg/GHC.framework/Versions/610/usr/bin"
    (prefix).install "ghc.pkg/GHC.framework/Versions/610/usr/lib"
    (prefix).install "ghc.pkg/GHC.framework/Versions/610/usr/share"
  end

  test do
    hello = (testpath/"hello.hs")
    hello.write('main = putStrLn "Hello Homebrew"')
    output = `echo "main" | '#{bin}/ghci' #{hello}`
    assert $?.success?
    assert_match /Hello Homebrew/i, output
  end
end
