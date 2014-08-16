require "formula"

class Openjpeg21 < Formula
  homepage "http://www.openjpeg.org/"
  url "https://downloads.sourceforge.net/project/openjpeg.mirror/2.1.0/openjpeg-2.1.0.tar.gz"
  sha1 "c2a255f6b51ca96dc85cd6e85c89d300018cb1cb"

  head "http://openjpeg.googlecode.com/svn/trunk"

  depends_on "cmake" => :build
  depends_on "little-cms2"
  depends_on "libtiff"
  depends_on "libpng"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
