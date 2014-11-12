require "formula"

class Freearc0666 < Formula
  homepage "http://freearc.org"
  url "http://freearc.org/download/0.666/FreeArc-0.666-sources.tar.bz2"
  sha1 "46da9b8ec33e1fc956a879ee439608c45b04a91e"
  version "0.666"

  resource "7zip" do
    url "https://sourceforge.net/projects/p7zip/files/p7zip/9.04/p7zip_9.04_src_all.tar.bz2/download"
    sha1 "6430fcd3a5e16d0a30f1eebf34a085e5372b813b"
  end
  
  depends_on "ghc610bin"
  #depends_on "gcc"
  
  #fails_with :clang

  #patch do
  #  url "file://" + File.dirname(__FILE__) + "/patches/freearc-0.666-osx.patch"
  #  sha1 ""
  #end

  def install
    ohai "THIS BUILD DIDN'T WORK!"
    
    resource("7zip").stage "#{buildpath}/7zip"

    system "chmod +x compile*"

    system "cd HsLua && make"

    # GHC 7.4.2 compatibility fixes
    #system "sed -i.bak -e 's/^import System.Posix.Internals/import System.Posix.Internals hiding (CFilePath)/' 'Files.hs'"
    #system "sed -i.bak -e 's/^import Foreign/import Foreign hiding (unsafePerformIO)/' 'Files.hs'"
    #system "sed -i.bak -e '3,4d' 'Compression/CompressionLib.hs'"
    #system "sed -i.bak -e 's/foreign import ccall threadsafe/foreign import ccall safe/' 'Compression/CompressionLib.hs'"

    system "./compile-O2"

    system "cd Unarc && make unix"
  end
end
