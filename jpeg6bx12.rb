require 'formula'

class Jpeg6bx12 < Formula
  homepage 'http://www.ijg.org'
  url 'http://www.ijg.org/files/jpegsrc.v6b.tar.gz'
  sha1 '7079f0d6c42fad0cfba382cf6ad322add1ace8f9'
  version '6bx12'

  depends_on 'libtool' => :build

  patch do
    url 'ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/delegates/ljpeg-6b.tar.gz'
    sha1 'ecc9b8c870c1a7de36b1b7021ee8c7396fa732c3'
  end

  def install
    bin.mkpath
    lib.mkpath
    include.mkpath
    man1.mkpath

    @bits_per_sample = "#{version}".gsub(/^.*x/, '')

    # adding binsuffix variable
    system 'sed', '-i', '', '-E', "/^binprefix =/ a\\\nbinsuffix = -#{version}\n", "makefile.cfg"
    # change version to resolve version-based linkign problems with other toolkits
    system 'sed', '-i', '', '-E', "s/^(JPEG_LIB_VERSION =).*/\\1 62#{@bits_per_sample.rjust(2, '0')}/", "makefile.cfg"
    # bug in original makefile
    system 'sed', '-i', '', '-E', "s/jclossy\\.o/jclossy.$(O)/", "makefile.cfg"
    # adding binsuffix to binary (exe/lib) files
    system 'sed', '-i', '', '-E', "s/(\\$\\(binprefix\\)[a-z]+)/\\1$(binsuffix)/", "makefile.cfg"
    # adding binsuffix to man files
    system 'sed', '-i', '', '-E', "s/(\\.\\$\\(manext\\))/$(binsuffix)\\1/", "makefile.cfg"
    # define bits per sample based on formula version
    system 'sed', '-i', '', '-E', "s/^(\#define BITS_IN_JSAMPLE ).*/\\1#{@bits_per_sample}/", "jmorecfg.h"
    # disable unsupported modules for other than 8 bits per samples builds
    system 'sed', '-i', '', '-E', "s/^\#define ((BMP|RLE|TARGA)_SUPPORTED)/#undef \\1/", "jconfig.cfg" if @bits_per_sample != "8"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"#,
                          #"--enable-static"
    
    system "mkdir", "#{include}/jpeg-#{version}"
    
    system "make", "install",
                   "install-lib",
                   "install-headers",
                   "mandir=#{man1}",
                   "includedir=#{include}/jpeg-#{version}",
                   "LIBTOOL=glibtool --tag=CC"
  end
end
