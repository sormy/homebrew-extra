require 'formula'

class Htmldoc < Formula
  homepage "http://www.msweet.org/projects.php?Z1"
  url "http://www.msweet.org/files/project1/htmldoc-1.8.28-source.tar.gz"
  sha256 "022a519cd868f36966dbda5e128368f134ac94418b68d7ca6be0794c61997d3a"

  depends_on "libpng"
  depends_on "jpeg"

  patch do
    url "file://" + File.dirname(__FILE__) + "/patches/htmldoc-cavok-patch-1.8.28.patch"
    sha256 "be6e8f0dd4f882d8960f27b533c62071b5c6384431cd70b404fc6ccbc994caf1"
  end

  def install
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make"
    system "make", "install"
  end
end
