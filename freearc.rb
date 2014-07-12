require "formula"

class Freearc < Formula
  homepage "http://freearc.org"
  url "http://freearc.org/download/0.666/FreeArc-0.666-sources.tar.bz2"
  sha1 "46da9b8ec33e1fc956a879ee439608c45b04a91e"
  version "0.666"

  depends_on "ghc610" => :build
  depends_on "wget" => :build
  depends_on "p7zip" => :build

  def install
    system "wget https://sourceforge.net/projects/p7zip/files/p7zip/9.04/p7zip_9.04_src_all.tar.bz2/download -O p7zip_9.04_src_all.tar.bz2"
    system "mkdir 7zip && tar xf p7zip_9.04_src_all.tar.bz2 -C 7zip"
    system "chmod +x compile*"
    system "cd HsLua && make"
    system "./compile-O2"
    system "cd Unarc && make unix"
  end
end
