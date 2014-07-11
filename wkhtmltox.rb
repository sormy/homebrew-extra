require "formula"

class Wkhtmltox < Formula
  homepage "http://wkhtmltopdf.org"

  url "http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.1/wkhtmltox-0.12.1_osx-cocoa-x86-64.pkg"
  version "0.12.1"
  sha1 "f9f4b7e00d811cbbc51f21879653e77dc539ba68"

  devel do
    url "http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.2-dev/wkhtmltox-0.12.2-6a13a51_osx-cocoa-x86-64.pkg"
    sha1 "82d9599c0077a6b3b33c4c0c01c435b2a19a790e"
    version "0.12.2-6a13a51"
  end

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
