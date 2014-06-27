require 'formula'

class Dcmtk < Formula
  homepage 'http://dicom.offis.de/dcmtk.php.en'
  url 'http://dicom.offis.de/download/dcmtk/snapshot/dcmtk-3.6.1_20140617.tar.gz'
  sha1 'f9d4d4d41e2d4189be7ccda302820b79b2163de9'
  version '3.6.1_20140617'
  
  head 'http://git.dcmtk.org/dcmtk.git'

  option 'with-docs', 'Install development libraries/headers and HTML docs'

  depends_on 'cmake' => :build
  depends_on 'libpng'
  depends_on 'libtiff'
  depends_on 'doxygen' if build.with? "docs"

  # This patch show element value offset in xml dump to process value raw in needed by external
  # application
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
diff -ur dcmtk-3.6.1_20131114/dcmdata/include/dcmtk/dcmdata/dcobject.h dcmtk-3.6.1_20131114-new/dcmdata/include/dcmtk/dcmdata/dcobject.h
--- dcmtk-3.6.1_20131114/dcmdata/include/dcmtk/dcmdata/dcobject.h 2013-11-14 18:08:01.000000000 +0400
+++ dcmtk-3.6.1_20131114-new/dcmdata/include/dcmtk/dcmdata/dcobject.h 2014-06-08 20:49:30.000000000 +0400
@@ -576,6 +576,9 @@
      */
     Uint32 getLengthField() const { return Length; }

+    Uint32 getFileOffset() const { return fOffset; }
+    void setFileOffset(Uint32 val) { fOffset = val; }
+
  protected:

     /** print line indentation, e.g. a couple of spaces for each nesting level.
@@ -745,6 +748,9 @@
     /// the length of this attribute as read from stream, may be undefined length
     Uint32 Length;

+    /// the element value offset in source file
+    Uint32 fOffset;
+
     /// transfer state during read and write operations
     E_TransferState fTransferState;

diff -ur dcmtk-3.6.1_20131114/dcmdata/libsrc/dcelem.cc dcmtk-3.6.1_20131114-new/dcmdata/libsrc/dcelem.cc
--- dcmtk-3.6.1_20131114/dcmdata/libsrc/dcelem.cc 2013-11-14 18:08:01.000000000 +0400
+++ dcmtk-3.6.1_20131114-new/dcmdata/libsrc/dcelem.cc 2014-06-08 22:03:43.000000000 +0400
@@ -1006,6 +1006,9 @@
         errorFlag = EC_IllegalCall;
     else
     {
+        if (getTransferState() == ERW_init)
+            setFileOffset(inStream.tell());
+
         /* if this is not an illegal call, go ahead and create a DcmXfer */
         /* object based on the transfer syntax which was passed */
         DcmXfer inXfer(ixfer);
@@ -1382,6 +1385,8 @@
         out << " vm=\"" << getVM() << "\"";
         /* value length in bytes = 0..max */
         out << " len=\"" << getLengthField() << "\"";
+        /* offset in bytes from beginning of file */
+        out << " offset=\"" << getFileOffset() << "\"";
         /* tag name (if known and not suppressed) */
         if (!(flags & DCMTypes::XF_omitDataElementName))
             out << " name=\"" << OFStandard::convertToMarkupString(getTagName(), xmlString) << "\"";
diff -ur dcmtk-3.6.1_20131114/dcmdata/libsrc/dcpxitem.cc dcmtk-3.6.1_20131114-new/dcmdata/libsrc/dcpxitem.cc
--- dcmtk-3.6.1_20131114/dcmdata/libsrc/dcpxitem.cc 2013-11-14 18:08:01.000000000 +0400
+++ dcmtk-3.6.1_20131114-new/dcmdata/libsrc/dcpxitem.cc 2014-06-08 21:29:08.000000000 +0400
@@ -214,6 +214,8 @@
     out << "<pixel-item";
     /* value length in bytes = 0..max */
     out << " len=\"" << getLengthField() << "\"";
+    /* offset in bytes from beginning of file */
+    out << " offset=\"" << getFileOffset() << "\"";
     /* value loaded = no (or absent)*/
     if (!valueLoaded())
         out << " loaded=\"no\"";
