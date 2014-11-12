require "formula"

class Freearc < Formula
  homepage "http://freearc.org"
  url "http://freearc.org/download/testing/FreeArc-0.67-alpha-sources.tar.bz2"
  sha1 "d79f57e48f31b57674c26b4d8b12b7f5ccd7f159"
  version "0.67.20140315"

  resource "7zip" do
    url "https://sourceforge.net/projects/sevenzip/files/7-Zip/9.10%20beta/7z910.tar.bz2/download"
    sha1 "94489abac55db207726a96fc6bfd30f5bf02e932"
  end

  depends_on "ghc742"

  def patches
    "file://" + File.dirname(__FILE__) + "/patches/freearc-0.67-osx.patch"
  end

  def install
    resource("7zip").stage "#{buildpath}/7zip"

    ohai "Status: "
    ohai "  HsLua => OK"
    ohai "  arc   => ERROR, 24 of 30 (with no 7zip, no lua, stubs)"
    ohai "  unarc => ERROR"

    #Dir.glob("**.hs") do |filename| 
    #    system "iconv -f cp1251 -t utf8 < #{filename} > #{filename}.new && mv -f #{filename}.new #{filename}"
    #end

    system "cd HsLua && make"

    # GHC 7.4.2 compatibility fixes
    system "sed -i.bak -e 's/foreign import ccall threadsafe/foreign import ccall safe/' 'Compression/CompressionLib.hs'"

    system "./compile-O2"

    system "cd Unarc && make unix"
  end
end
