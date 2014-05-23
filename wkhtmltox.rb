require "formula"

class Wkhtmltox < Formula
  homepage "http://wkhtmltopdf.org"
  url "http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.1-dev/wkhtmltox-0.12.1-7fac78c_osx-10.9-cocoa-x86-64.tar.xz"
  sha1 "7210f18f4023e0c0b8e6588d25d80d2e7e2c1591"
  version "0.12.1-7fac78c"

  def install
    bin.install Dir['bin/*']
    lib.install Dir['lib/*']
    include.install Dir['include/*']
  end
end
