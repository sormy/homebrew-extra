require "formula"

# ported to 9.3.1 based on 
# https://github.com/kadishmal/cubrid-mac-os-x

class CubridCci < Formula
  homepage "http://www.cubrid.org"
  url "http://svn.cubrid.org/cubridengine/tags/9.3_Patch_1", :using => :svn
  version "9.3.1.0005"

  patch do
    url "file://" + File.dirname(__FILE__) + "/patches/cubrid-9.3.1-osx.patch"
    sha1 "715770d4c97067d82c3b5f511936cee0cbc3a114"
  end

  depends_on "coreutils"
  depends_on "automake"
  depends_on "autoconf"
  depends_on "libtool"
  
  def install
    Dir.glob('./external/*/configure.gnu') do |file|
      inreplace file, "readlink", "greadlink"
    end

    inreplace "./autogen.sh", "libtoolize", "glibtoolize"

    File.chmod 0755, "./autogen.sh"
    File.chmod 0755, "./external/libregex38a/install-sh"

    Dir.glob('./external/*/configure') do |file|
      File.chmod 0755, file
    end

    system "./autogen.sh"

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-64bit"

    system "cd external && make"
    
    system "cd cci && make && make install"
  end
end
