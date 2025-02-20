# src/unix/sun/sun/awt/motif/font.properties.ru, a112, a112, a112-19970718 97/07/01
#
#  Copyright (c) 1994-1996 by Sun Microsystems Inc
#  Copyright (c) 1997 by IBM Corporation
#
# Russian AWT Font Properties for AIX
#

# Serif font definition
#
serif.0=-monotype-times new roman-medium-r-normal--*-%d-*-*-p-*-iso8859-5
serif.1=-adobe-times-medium-r-normal--*-%d-*-*-p-*-iso8859-1
serif.2=-adobe-symbol-medium-r-normal--*-%d-*-*-p-*-adobe-fontspecific

serif.italic.0=-monotype-times new roman-medium-i-normal--*-%d-*-*-p-*-iso8859-5
serif.italic.1=-adobe-times-medium-i-normal--*-%d-*-*-p-*-iso8859-1

serif.bold.0=-monotype-times new roman-bold-r-normal--*-%d-*-*-p-*-iso8859-5
serif.bold.1=-adobe-times-bold-r-normal--*-%d-*-*-p-*-iso8859-1

# SansSerif font definition
#
sansserif.0=-linotype-helvetica-medium-r-normal--*-%d-*-*-p-*-iso8859-5
sansserif.1=-adobe-helvetica-medium-r-normal--*-%d-*-*-p-*-iso8859-1
sansserif.2=-adobe-symbol-medium-r-normal--*-%d-*-*-p-*-adobe-fontspecific

sansserif.italic.0=-linotype-helvetica-medium-i-normal--*-%d-*-*-p-*-iso8859-5
sansserif.italic.1=-adobe-helvetica-medium-o-normal--*-%d-*-*-p-*-iso8859-1

sansserif.bold.0=-linotype-helvetica-bold-r-normal--*-%d-*-*-p-*-iso8859-5
sansserif.bold.1=-adobe-helvetica-bold-r-normal--*-%d-*-*-p-*-iso8859-1

# Monospaced font definition
#
monospaced.0=-urw-courier-medium-r-normal--*-%d-*-*-m-*-iso8859-5
monospaced.1=-adobe-courier-medium-r-normal--*-%d-*-*-m-*-iso8859-1
monospaced.2=-adobe-symbol-medium-r-normal--*-%d-*-*-p-*-adobe-fontspecific

monospaced.italic.0=-urw-courier-medium-i-normal--*-%d-*-*-m-*-iso8859-5
monospaced.italic.1=-adobe-courier-medium-o-normal--*-%d-*-*-m-*-iso8859-1

monospaced.bold.0=-urw-courier-bold-r-normal--*-%d-*-*-m-*-iso8859-5
monospaced.bold.1=-adobe-courier-bold-r-normal--*-%d-*-*-m-*-iso8859-1

# Dialog font definition
#
dialog.0=-ibm-block-medium-r-normal--*-%d-*-*-c-*-iso8859-5
dialog.1=-ibm-block-medium-r-normal--*-%d-*-*-c-*-iso8859-1
dialog.2=-adobe-symbol-medium-r-normal--*-%d-*-*-p-*-adobe-fontspecific

dialog.italic.0=-ibm-block-medium-i-normal--*-%d-*-*-c-*-iso8859-5
dialog.italic.1=-ibm-block-medium-i-normal--*-%d-*-*-c-*-iso8859-1

dialog.bold.0=-ibm-block-bold-r-normal--*-%d-*-*-c-*-iso8859-5
dialog.bold.1=-ibm-block-bold-r-normal--*-%d-*-*-c-*-iso8859-1

# DialogInput font definition
#
dialoginput.0=-ibm-block-medium-r-normal--*-%d-*-*-c-*-iso8859-5
dialoginput.1=-ibm-block-medium-r-normal--*-%d-*-*-c-*-iso8859-1
dialoginput.2=-adobe-symbol-medium-r-normal--*-%d-*-*-p-*-adobe-fontspecific

dialoginput.italic.0=-ibm-block-medium-i-normal--*-%d-*-*-c-*-iso8859-5
dialoginput.italic.1=-ibm-block-medium-i-normal--*-%d-*-*-c-*-iso8859-1

dialoginput.bold.0=-ibm-block-bold-r-normal--*-%d-*-*-c-*-iso8859-5
dialoginput.bold.1=-ibm-block-bold-r-normal--*-%d-*-*-c-*-iso8859-1

# Default font definition
#
default.char=0

# name aliases
#
alias.timesroman=serif
alias.helvetica=sansserif
alias.courier=monospaced

# for backward compatibility
zapfdingbats.0=-urw-itc zapfdingbats-medium-r-normal--*-%d-*-*-p-*-sun-fontspecific

# Static FontCharset info.
#
# This information is used by the font which is not indexed by Unicode.
# Such fonts can use their own subclass of FontCharset.
#
# This information can be overriden by describing more specific style.
# For example
#
#  fontcharset.serif.plain.3=SpecialSymbols
#  means serif.plain.3 font's index can be retrieved with the convert() method
#  of instance of SpecialSymbols and what kind of characters serif.plain.3 font
#  has can be judged with the isCovered() method of instance of SpecialSymbols.
#
fontcharset.serif.0=sun.io.CharToByte8859_5
fontcharset.serif.1=sun.io.CharToByte8859_1 
fontcharset.serif.2=sun.awt.CharToByteSymbol


fontcharset.sansserif.0=sun.io.CharToByte8859_5
fontcharset.sansserif.1=sun.io.CharToByte8859_1
fontcharset.sansserif.2=sun.awt.CharToByteSymbol


fontcharset.monospaced.0=sun.io.CharToByte8859_5
fontcharset.monospaced.1=sun.io.CharToByte8859_1
fontcharset.monospaced.2=sun.awt.CharToByteSymbol


fontcharset.dialog.0=sun.io.CharToByte8859_5
fontcharset.dialog.1=sun.io.CharToByte8859_1
fontcharset.dialog.2=sun.awt.CharToByteSymbol


fontcharset.dialoginput.0=sun.io.CharToByte8859_5
fontcharset.dialoginput.1=sun.io.CharToByte8859_1
fontcharset.dialoginput.2=sun.awt.CharToByteSymbol


# exclusion info.
#
# This information describe exclusion ranges for each fonts.
#
# 'exclusion.serif.plain.0' overrides 'exclusion.serif.0', and
# 'exclusion.serif.0' overrides exclusion.0, and so on.
#

# XFontSet string
# X11 only properties
#

fontset.serif.plain=\
-monotype-times new roman-medium-r-normal--*-%d-*-*-p-*-iso8859-5

fontset.serif.italic=\
-monotype-times new roman-medium-i-normal--*-%d-*-*-p-*-iso8859-5

fontset.serif.bold=\
-monotype-times new roman-bold-r-normal--*-%d-*-*-p-*-iso8859-5

fontset.sansserif.italic=\
-linotype-helvetica-medium-i-normal--*-%d-*-*-p-*-iso8859-5
 
fontset.sansserif.bold=\
-linotype-helvetica-bold-r-normal--*-%d-*-*-p-*-iso8859-5
 
fontset.sansserif.plain=\
-linotype-helvetica-medium-r-normal--*-%d-*-*-p-*-iso8859-5

fontset.monospaced.italic=\
-urw-courier-medium-i-normal--*-%d-*-*-m-*-iso8859-5
 
fontset.monospaced.bold=\
-urw-courier-bold-r-normal--*-%d-*-*-m-*-iso8859-5
 
fontset.monospaced.plain=\
-urw-courier-medium-r-normal--*-%d-*-*-m-*-iso8859-5
 
fontset.dialog.italic=\
-ibm-block-medium-i-normal--*-%d-*-*-c-*-iso8859-5

fontset.dialog.bold=\
-ibm-block-bold-r-normal--*-%d-*-*-c-*-iso8859-5 

fontset.dialog.plain=\
-ibm-block-medium-r-normal--*-%d-*-*-c-*-iso8859-5

fontset.dialoginput.italic=\
-ibm-block-medium-i-normal--*-%d-*-*-c-*-iso8859-5

fontset.dialoginput.bold=\
-ibm-block-bold-r-normal--*-%d-*-*-c-*-iso8859-5

fontset.dialoginput.plain=\
-ibm-block-medium-r-normal--*-%d-*-*-c-*-iso8859-5

#
fontset.default=\
-ibm-block-medium-r-normal--*-%d-*-*-c-*-iso8859-5
#
