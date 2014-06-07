require 'formula'

class Dcmtk < Formula
  homepage 'http://dicom.offis.de/dcmtk.php.en'
  url 'http://dicom.offis.de/download/dcmtk/snapshot/dcmtk-3.6.1_20131114.tar.gz'
  sha1 'a6b5f8b1f4a78a3955e2084919f9b9e346f1c6de'

  option 'with-docs', 'Install development libraries/headers and HTML docs'

  depends_on 'cmake' => :build
  depends_on 'libpng'
  depends_on 'libtiff'
  depends_on 'doxygen' if build.with? "docs"

  # This roughly corresponds to thefollowing upstream patch:
  #
  #   http://git.dcmtk.org/web?p=dcmtk.git;a=commitdiff;h=dbadc0d8f3760f65504406c8b2cb8633f868a258
  #
  # However, this patch can't be applied as-is, since it refers to
  # some files that don't exist in the 3.6.0 release.
  #
  # This patch can be dropped once DCMTK makes a new release, but
  # since this is a very rare occurrence (the last development preview
  # release is from mid 2012), it seems justifiable to keep the patch
  # ourselves for a while.
  patch :DATA

  def install
    ENV.m64 if MacOS.prefer_64_bit?

    args = std_cmake_args
    args << '-DDCMTK_WITH_DOXYGEN=YES' if build.with? "docs"
    args << '..'

    mkdir 'build' do
      system 'cmake', *args
      system 'make DOXYGEN' if build.with? "docs"
      system 'make install'
    end
  end
end

__END__
diff -ur dcmtk-3.6.0/dcmdata/include/dcmtk/dcmdata/dcobject.h dcmtk-3.6.0-new/dcmdata/include/dcmtk/dcmdata/dcobject.h
--- dcmtk-3.6.0/dcmdata/include/dcmtk/dcmdata/dcobject.h	2010-10-29 14:57:17.000000000 +0400
+++ dcmtk-3.6.0-new/dcmdata/include/dcmtk/dcmdata/dcobject.h	2014-06-08 01:53:53.000000000 +0400
@@ -503,6 +503,9 @@
      */
     Uint32 getLengthField() const { return Length; }
 
+    Uint32 getOffset() const { return Offset; }
+    void setOffset(Uint32 newOffset) { Offset = newOffset; }
+
  protected:
 
     /** print line indentation, e.g. a couple of spaces for each nesting level.
@@ -671,6 +674,9 @@
     /// the length of this attribute as read from stream, may be undefined length
     Uint32 Length;
 
+    /// orignal file offset to read value from source file
+    Uint32 Offset;
+
     /// transfer state during read and write operations
     E_TransferState fTransferState;
 
diff -ur dcmtk-3.6.0/dcmdata/libsrc/dcelem.cc dcmtk-3.6.0-new/dcmdata/libsrc/dcelem.cc
--- dcmtk-3.6.0/dcmdata/libsrc/dcelem.cc	2010-11-05 12:34:14.000000000 +0300
+++ dcmtk-3.6.0-new/dcmdata/libsrc/dcelem.cc	2014-06-08 01:54:13.000000000 +0400
@@ -1049,6 +1049,8 @@
             }
             /* if the transfer state is ERW_inWork and we are not supposed */
             /* to read this element's value later, read the value now */
+            if (getTransferState() == ERW_inWork)
+                setOffset(inStream.tell());
             if (getTransferState() == ERW_inWork && !fLoadValue)
                 errorFlag = loadValue(&inStream);
             /* if the amount of transferred bytes equals the Length of this element */
@@ -1283,6 +1285,8 @@
     out << " vm=\"" << getVM() << "\"";
     /* value length in bytes = 0..max */
     out << " len=\"" << getLengthField() << "\"";
+    /* offset in bytes from beginning of file */
+    out << " offset=\"" << getOffset() << "\"";
     /* tag name (if known and not suppressed) */
     if (!(flags & DCMTypes::XF_omitDataElementName))
         out << " name=\"" << OFStandard::convertToMarkupString(getTagName(), xmlString) << "\"";
