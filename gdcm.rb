require 'formula'

class Gdcm < Formula
  homepage 'http://gdcm.sourceforge.net'
  url 'http://downloads.sourceforge.net/project/gdcm/gdcm%202.x/GDCM%202.4.1/gdcm-2.4.1.tar.bz2'
  sha1 '1ba1b46455b962d78f0ad4863872ab06019f3c23'

  depends_on 'cmake' => :build

  def install
    # See http://librelist.com/browser//homebrew/2013/5/27/separating-source-and-binary-trees-during-build/#d95fad118a1e3b6d29a474bf66e92802
    mkdir '../build' do
      system 'cmake', buildpath,
      '-DGDCM_BUILD_APPLICATIONS:BOOL=ON', *std_cmake_args
      system "make", "install"
    end
  end

  test do
    system "#{bin}/gdcmconv", '--version'
  end
end
