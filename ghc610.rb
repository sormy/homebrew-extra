require 'formula'

class PkgCurlDownloadStrategy <CurlDownloadStrategy
  def stage
    safe_system '/usr/sbin/pkgutil', '--expand', @tarball_path, File.basename(@url)
    chdir
  end
end

# Remember to update the formula for Cabal when updating this formula
class Ghc610 <Formula
  homepage 'http://haskell.org/ghc/'
  version '6.10.4'
  url "http://www.haskell.org/ghc/dist/#{version}/GHC-#{version}-i386.pkg"
  sha1 '849d2bb2108de6f830e2d99f410734f5502b13d1'

  # Avoid stripping the Haskell binaries AND libraries; http://hackage.haskell.org/trac/ghc/ticket/2458
  skip_clean ['bin', 'lib']

  def download_strategy
    # Extract files from .pkg while caching the .pkg
    PkgCurlDownloadStrategy
  end

  def replace_all foo, bar
    # Find all text files containing foo and replace it with bar
    files = `/usr/bin/grep -lsIR #{foo} .`.split
    inreplace files, foo, bar
  end

  def install
    short_version = "610"

    # Extract files from .pax.gz
    system '/bin/pax -f ghc.pkg/Payload -p p -rz'
    cd "GHC.framework/Versions/#{short_version}/usr"

    # Fix paths
    replace_all "/Library/Frameworks/GHC.framework/Versions/#{short_version}/usr/lib/ghc-#{version}", "#{lib}/ghc"
    replace_all "/Library/Frameworks/GHC.framework/Versions/#{short_version}/usr", prefix
    inreplace "lib/ghc-#{version}/ghc-asm", "#!/usr/bin/perl", "#!/usr/bin/env perl"
    mv "lib/ghc-#{version}", 'lib/ghc'

    prefix.install ['bin', 'lib', 'share']
  end
end
