require File.join(File.dirname(__FILE__), '../../homebrew/homebrew-php/Abstract/abstract-php-extension')

class Php56Spidermonkey < AbstractPhp56Extension
  init
  homepage 'https://github.com/christopherobin/php-spidermonkey/'
  url 'http://pecl.php.net/get/spidermonkey-1.0.0.tgz'
  sha1 '5f892747d755cf562f1a1a55125bab041ddd5fcb'
  version '1.0.0'
  head 'https://github.com/christopherobin/php-spidermonkey.git'

  depends_on 'spidermonkey'

  stable do
    patch :p0, :DATA
  end

  def install
    Dir.chdir "spidermonkey-#{version}" if Dir.exists? "spidermonkey-#{version}"

    ENV.universal_binary if build.universal?

    safe_phpize
    system "./configure", "--prefix=#{prefix}",
                          phpconfig,
                          "--with-spidermonkey=#{Formula['spidermonkey'].opt_prefix}"
    system "make"
    prefix.install "modules/spidermonkey.so"
    write_config_file if build.with? "config-file"
  end
end

__END__
--- spidermonkey-1.0.0/config.m4   2014-07-28 15:54:28.000000000 -0400
+++ spidermonkey-1.0.0/config.m4   2014-07-28 15:59:36.000000000 -0400
@@ -36,7 +36,7 @@
     done
     # test for the libname independantely
     for j in js mozjs mozjs185; do
-      test -f $i/lib/lib$j.so && SPIDERMONKEY_LIBNAME=$j && break
+      test -f $i/lib/lib$j.dylib && SPIDERMONKEY_LIBNAME=$j && break
     done
     test -f $i/include/$j/jsapi.h && break
   done
