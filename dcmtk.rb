class Dcmtk < Formula
  desc "OFFIS DICOM toolkit command-line utilities"
  homepage "http://dicom.offis.de/dcmtk.php.en"
  
  # Current snapshot used for stable now.
  url "http://dicom.offis.de/download/dcmtk/snapshot/dcmtk-3.6.1_20150629.tar.gz"
  sha256 "6af8a4683a8f4995cefbad00e727fd760e0e5f535d7c4ad622ce280a701888e2"
  version "3.6.1-20150629"
  
  head "http://git.dcmtk.org/dcmtk.git"

  option "with-docs", "Install development libraries/headers and HTML docs"
  option "with-openssl", "Configure DCMTK with support for OpenSSL"
  option "with-libiconv", "Build with brewed libiconv. Dcmtk and system libiconv can have problems with utf8."

  depends_on "cmake" => :build
  depends_on "doxygen" => :build if build.with? "docs"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "openssl"
  depends_on "homebrew/dupes/libiconv" => :optional

  patch do
    url "file://" + File.dirname(__FILE__) + "/patches/dcmtk-3.6.1-dcm2xml-offsets.patch"
    sha1 "72dfe84a46fa98d2069d48266744c4d908cb0037"
  end

  patch do
    url "file://" + File.dirname(__FILE__) + "/patches/dcmtk-3.6.1-dcm2xml-rd.patch"
    sha1 "2a934a6c99d9ac985f2a72cb1a47d736439c3ab8"
  end

  def install
    ENV.m64 if MacOS.prefer_64_bit?

    args = std_cmake_args
    args << "-DDCMTK_WITH_DOXYGEN=YES" if build.with? "docs"
    args << "-DDCMTK_WITH_OPENSSL=YES" if build.with? "openssl"
    args << "-DDCMTK_WITH_ICONV=YES -DLIBICONV_DIR=#{Formula["libiconv"].opt_prefix}" if build.with? "libiconv"
    args << ".."

    mkdir "build" do
      system "cmake", *args
      system "make", "DOXYGEN" if build.with? "docs"
      system "make", "install"
    end
  end

  test do
    system bin/"pdf2dcm", "--verbose",
           test_fixtures("test.pdf"), testpath/"out.dcm"
    system bin/"dcmftest", testpath/"out.dcm"
  end
end
