require 'formula'

class Dcmtk < Formula
  homepage 'http://dicom.offis.de/dcmtk.php.en'
  url 'http://dicom.offis.de/download/dcmtk/snapshot/dcmtk-3.6.1_20140617.tar.gz'
  sha1 'f9d4d4d41e2d4189be7ccda302820b79b2163de9'
  version '3.6.1_20140617'
  
  head 'http://git.dcmtk.org/dcmtk.git'

  option 'with-docs', 'Install development libraries/headers and HTML docs'
  option 'with-openssl', 'Configure DCMTK with support for OpenSSL'
  
  depends_on 'cmake' => :build
  depends_on 'libpng'
  depends_on 'libtiff'
  depends_on 'doxygen' if build.with? "docs"

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
    args << '-DDCMTK_WITH_DOXYGEN=YES' if build.with? "docs"
    args << '-DDCMTK_WITH_OPENSSL=YES' if build.with? "openssl"
    args << '..'

    mkdir 'build' do
      system 'cmake', *args
      system 'make DOXYGEN' if build.with? "docs"
      system 'make install'
    end
  end
end
