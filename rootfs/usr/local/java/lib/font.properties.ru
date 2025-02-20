# @(#)font.properties.ru        1.2 97/03/03
#
#  Copyright (c) 1994-1996 by Sun Microsystems Inc
#
# AWT Font default Properties for Cyrillic *NIX
# (modified by  A. Farber,  alex@kawo2.rwth-aachen.de)

# Serif font definition
#
serif.plain.0=-*-times-medium-r-normal--*-%d-*-*-p-*-iso8859-1
serif.plain.1=-*-times-medium-r-normal--*-%d-*-*-p-*-koi8-r
serif.2=-*-symbol-medium-r-normal--*-%d-*-*-p-*-*-fontspecific

serif.italic.0=-*-times-medium-i-normal--*-%d-*-*-p-*-iso8859-1
serif.italic.1=-*-times-medium-i-normal--*-%d-*-*-p-*-koi8-r

serif.bold.0=-*-times-bold-r-normal--*-%d-*-*-p-*-iso8859-1
serif.bold.1=-*-times-bold-r-normal--*-%d-*-*-p-*-koi8-r

serif.bolditalic.0=-*-times-bold-i-normal--*-%d-*-*-p-*-iso8859-1
serif.bolditalic.1=-*-times-bold-i-normal--*-%d-*-*-p-*-koi8-r

# SansSerif font definition
#
sansserif.plain.0=-*-helvetica-medium-r-normal--*-%d-*-*-p-*-iso8859-1
sansserif.plain.1=-*-helvetica-medium-r-normal--*-%d-*-*-p-*-koi8-r
sansserif.2=-*-symbol-medium-r-normal--*-%d-*-*-p-*-*-fontspecific

sansserif.italic.0=-*-helvetica-medium-o-normal--*-%d-*-*-p-*-iso8859-1
sansserif.italic.1=-*-helvetica-medium-o-normal--*-%d-*-*-p-*-koi8-r

sansserif.bold.0=-*-helvetica-bold-r-normal--*-%d-*-*-p-*-iso8859-1
sansserif.bold.1=-*-helvetica-bold-r-normal--*-%d-*-*-p-*-koi8-r

sansserif.bolditalic.0=-*-helvetica-bold-o-normal--*-%d-*-*-p-*-iso8859-1
sansserif.bolditalic.1=-*-helvetica-bold-o-normal--*-%d-*-*-p-*-koi8-r

# Monospaced font definition
#
monospaced.plain.0=-*-courier-medium-r-normal--*-%d-*-*-m-*-iso8859-1
monospaced.plain.1=-*-helvetica-medium-r-normal--*-%d-*-*-p-*-koi8-r
monospaced.2=-*-symbol-medium-r-normal--*-%d-*-*-p-*-*-fontspecific

monospaced.italic.0=-*-courier-medium-o-normal--*-%d-*-*-m-*-iso8859-1
monospaced.italic.1=-*-courier-medium-o-normal--*-%d-*-*-m-*-koi8-r

monospaced.bold.0=-*-courier-bold-r-normal--*-%d-*-*-m-*-iso8859-1
monospaced.bold.1=-*-courier-bold-r-normal--*-%d-*-*-m-*-koi8-r

monospaced.bolditalic.0=-*-courier-bold-o-normal--*-%d-*-*-m-*-iso8859-1
monospaced.bolditalic.1=-*-courier-bold-o-normal--*-%d-*-*-m-*-koi8-r

# Dialog font definition
#
dialog.plain.0=-*-helvetica-medium-r-normal--*-%d-*-*-p-*-iso8859-1
dialog.plain.1=-*-helvetica-medium-r-normal--*-%d-*-*-p-*-koi8-r
dialog.2=-*-symbol-medium-r-normal--*-%d-*-*-p-*-*-fontspecific

dialog.italic.0=-*-helvetica-medium-o-normal--*-%d-*-*-p-*-iso8859-1
dialog.italic.1=-*-helvetica-medium-o-normal--*-%d-*-*-p-*-koi8-r

dialog.bold.0=-*-helvetica-bold-r-normal--*-%d-*-*-p-*-iso8859-1
dialog.bold.1=-*-helvetica-bold-r-normal--*-%d-*-*-p-*-koi8-r

dialog.bolditalic.0=-*-helvetica-bold-o-normal--*-%d-*-*-p-*-iso8859-1
dialog.bolditalic.1=-*-helvetica-bold-o-normal--*-%d-*-*-p-*-koi8-r

# DialogInput font definition
#
dialoginput.plain.0=-*-courier-medium-r-normal--*-%d-*-*-m-*-iso8859-1
dialoginput.plain.1=-*-courier-medium-r-normal--*-%d-*-*-m-*-koi8-r
dialoginput.2=-*-symbol-medium-r-normal--*-%d-*-*-p-*-*-fontspecific

dialoginput.italic.0=-*-courier-medium-o-normal--*-%d-*-*-m-*-iso8859-1
dialoginput.italic.1=-*-courier-medium-o-normal--*-%d-*-*-m-*-koi8-r

dialoginput.bold.0=-*-courier-bold-r-normal--*-%d-*-*-m-*-iso8859-1
dialoginput.bold.1=-*-courier-bold-r-normal--*-%d-*-*-m-*-koi8-r

dialoginput.bolditalic.0=-*-courier-bold-o-normal--*-%d-*-*-m-*-iso8859-1
dialoginput.bolditalic.1=-*-courier-bold-o-normal--*-%d-*-*-m-*-koi8-r

# Default font definition
#
default.char=274f

# name aliases
#
alias.timesroman=serif
alias.helvetica=sansserif
alias.courier=monospaced

# for backward compatibility
zapfdingbats.0=-*-symbol-medium-r-normal--*-%d-*-*-p-*-*-fontspecific

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
fontcharset.serif.0=sun.io.CharToByte8859_1 
fontcharset.serif.1=sun.io.CharToByteKOI8_R
fontcharset.serif.2=sun.awt.CharToByteSymbol

fontcharset.sansserif.0=sun.io.CharToByte8859_1
fontcharset.sansserif.1=sun.io.CharToByteKOI8_R
fontcharset.sansserif.2=sun.awt.CharToByteSymbol

fontcharset.monospaced.0=sun.io.CharToByte8859_1
fontcharset.monospaced.1=sun.io.CharToByteKOI8_R
fontcharset.monospaced.2=sun.awt.CharToByteSymbol

fontcharset.dialog.0=sun.io.CharToByte8859_1
fontcharset.dialog.1=sun.io.CharToByteKOI8_R
fontcharset.dialog.2=sun.awt.CharToByteSymbol

fontcharset.dialoginput.0=sun.io.CharToByte8859_1
fontcharset.dialoginput.1=sun.io.CharToByteKOI8_R
fontcharset.dialoginput.2=sun.awt.CharToByteSymbol

fontcharset.zapfdingbats.0=sun.io.CharToByte8859_1

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
fontset.default=\
-*-times-medium-r-normal--*-%d-*-*-p-*-koi8-r
#
