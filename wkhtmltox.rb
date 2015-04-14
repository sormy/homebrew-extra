require "formula"

class Wkhtmltox < Formula
  homepage "http://wkhtmltopdf.org"

  url "http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.2.1/wkhtmltox-0.12.2.1_osx-cocoa-x86-64.pkg"
  version "0.12.2.1"
  sha1 "066019461b5e2e0ec88dacd009494fb3a8afad07"

  depends_on "xz" => :build

  def install
    system "cat Payload | gunzip -dc | cpio -i"
    system "xz -d usr/local/share/wkhtmltox-installer/app.tar.xz"
    system "tar -xf usr/local/share/wkhtmltox-installer/app.tar"

    bin.install Dir['bin/*']
    lib.install Dir['lib/*']
    include.install Dir['include/*']
    man1.install Dir['share/man/man1/*']
  end
end
