require 'formula'

class Htmldoc < Formula
  homepage "http://www.msweet.org/projects.php?Z1"
  url "http://www.msweet.org/files/project1/htmldoc-1.8.27-source.tar.gz"
  sha256 "64f6d9f40f00f9cc68df6508123e88ed30fef924881fd28dca45358ecd79d320"

  depends_on "libpng"
  depends_on "jpeg"
  
  patch do
    url "file://" + File.dirname(__FILE__) + "/patches/htmldoc-cavok-patch-1.8.27.patch"
    sha256 "265354b0857d6c872119c57b6e6d0fe895f2a3058337b593f638f61b4ef412bf"
  end

  def install
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make"
    system "make", "install"
  end
end
