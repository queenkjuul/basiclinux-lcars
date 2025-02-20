# @(#)font.properties.cs	1.2 97/03/03
#
#  Copyright (c) 1994-1996 by Sun Microsystems Inc
#
# AWT Czech Font Properties for HP-UX (for JVM's running in the
# cs_CZ.iso88592 locale)

# Note:  This file contains entries for use with outline fonts available
# from the X Font Server.  However, since the X Font Server is not
# configured by default on HP systems, the outline fonts referenced in
# this file are commented out.  To use the outline fonts, uncomment the
# lines containing -agfa-, and comment out the corresponding entry in the
# same set.  This will be for the .0 font entries, such as timesroman.plain.0
# and timesroman.bold.0.

# Serif font definition
#
serif.plain.0=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2
serif.1=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2
serif.2=-urw-itc zapfdingbats-medium-r-normal--*-%d-*-*-p-*-sun-fontspecific
serif.3=--symbol-medium-r-normal--*-%d-*-*-p-*-sun-fontspecific

serif.italic.0=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2

serif.bold.0=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2

serif.bolditalic.0=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2

# SansSerif font definition
#
sansserif.plain.0=-hp-hp system-medium-r-normal--*-%d-*-*-p-*-iso8859-2
sansserif.1=-hp-hp system-medium-r-normal--*-%d-*-*-p-*-iso8859-2
sansserif.2=-urw-itc zapfdingbats-medium-r-normal--*-%d-*-*-p-*-sun-fontspecific
sansserif.3=--symbol-medium-r-normal--*-%d-*-*-p-*-sun-fontspecific

sansserif.italic.0=-hp-hp system-medium-r-normal--*-%d-*-*-p-*-iso8859-2

sansserif.bold.0=-hp-hp system-bold-r-normal--*-%d-*-*-p-*-iso8859-2
sansserif.bold.1=-hp-hp system-bold-r-normal--*-%d-*-*-p-*-iso8859-2

sansserif.bolditalic.0=-hp-hp system-bold-r-normal--*-%d-*-*-p-*-iso8859-2
sansserif.bolditalic.1=-hp-hp system-bold-r-normal--*-%d-*-*-p-*-iso8859-2

# Monospaced font definition
#
monospaced.plain.0=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2
monospaced.1=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2
monospaced.2=-urw-itc zapfdingbats-medium-r-normal--*-%d-*-*-p-*-sun-fontspecific
monospaced.3=--symbol-medium-r-normal--*-%d-*-*-p-*-sun-fontspecific

monospaced.italic.0=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2

monospaced.bold.0=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2

monospaced.bolditalic.0=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2


# Dialog font definition
#
dialog.plain.0=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2
dialog.1=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2
dialog.2=-urw-itc zapfdingbats-medium-r-normal--*-%d-*-*-p-*-sun-fontspecific
dialog.3=--symbol-medium-r-normal--*-%d-*-*-p-*-sun-fontspecific

dialog.italic.0=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2

dialog.bold.0=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2

dialog.bolditalic.0=-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2


# DialogInput font definition
#
dialoginput.plain.0=-hp-hp system-medium-r-normal--*-%d-*-*-p-*-iso8859-2
dialoginput.1=-hp-hp system-medium-r-normal--*-%d-*-*-p-*-iso8859-2
dialoginput.2=-urw-itc zapfdingbats-medium-r-normal--*-%d-*-*-p-*-sun-fontspecific
dialoginput.3=--symbol-medium-r-normal--*-%d-*-*-p-*-sun-fontspecific

dialoginput.italic.0=-hp-hp system-medium-r-normal--*-%d-*-*-p-*-iso8859-2

dialoginput.bold.0=-hp-hp system-bold-r-normal--*-%d-*-*-p-*-iso8859-2
dialoginput.bold.1=-hp-hp system-bold-r-normal--*-%d-*-*-p-*-iso8859-2

dialoginput.bolditalic.0=-hp-hp system-bold-r-normal--*-%d-*-*-p-*-iso8859-2
dialoginput.bolditalic.1=-hp-hp system-bold-r-normal--*-%d-*-*-p-*-iso8859-2

# Default font definition
#
default.char=274f

# name aliases
#
# alias.timesroman=serif
# alias.helvetica=sansserif
# alias.courier=monospaced

# for backward compatibility
#timesroman.plain.0=-agfa-cgtimes-medium-r-normal--*-%d-*-*-p-*-iso8859-1
#timesroman.italic.0=-agfa-cgtimes-medium-i-normal--*-%d-*-*-p-*-iso8859-1
#timesroman.bold.0=-agfa-cgtimes-bold-r-normal--*-%d-*-*-p-*-iso8859-1
#timesroman.bolditalic.0=-agfa-cgtimes bolditalic-bold-i-normal--*-%d-*-*-p-*-is
o8859-1
timesroman.plain.0=-adobe-times-medium-r-normal--*-%d-*-*-p-*-iso8859-1
timesroman.italic.0=-adobe-times-medium-i-normal--*-%d-*-*-p-*-iso8859-1
timesroman.bold.0=-adobe-times-bold-r-normal--*-%d-*-*-p-*-iso8859-1
timesroman.bolditalic.0=-adobe-times-bold-i-normal--*-%d-*-*-p-*-iso8859-1
#
#helvetica.plain.0=-agfa-univers-medium-r-normal--*-%d-*-*-p-*-iso8859-1
#helvetica.italic.0=-agfa-univers-medium-i-normal--*-%d-*-*-p-*-iso8859-1
#helvetica.bold.0=-agfa-univers-bold-r-normal--*-%d-*-*-p-*-iso8859-1
#helvetica.bolditalic.0=-agfa-univers-bold-i-normal--*-%d-*-*-p-*-iso8859-1
helvetica.plain.0=-adobe-helvetica-medium-r-normal--*-%d-*-*-p-*-iso8859-1
helvetica.italic.0=-adobe-helvetica-medium-o-normal--*-%d-*-*-p-*-iso8859-1
helvetica.bold.0=-adobe-helvetica-bold-r-normal--*-%d-*-*-p-*-iso8859-1
helvetica.bolditalic.0=-adobe-helvetica-bold-o-normal--*-%d-*-*-p-*-iso8859-1
#
#courier.plain.0=-agfa-courier-normal-r-normal-*-*-%d-*-*-m-*-iso8859-1
#courier.italic.0=-agfa-courier-normal-o-normal-*-*-%d-*-*-m-*-iso8859-1
#courier.bold.0=-agfa-courier-bold-r-normal-*-*-%d-*-*-m-*-iso8859-1
#courier.bolditalic.0=-agfa-courier-bold-i-normal-*-*-%d-*-*-m-*-iso8859-1
courier.plain.0=-adobe-courier-medium-r-normal--*-%d-*-*-m-*-iso8859-1
courier.italic.0=-adobe-courier-medium-o-normal--*-%d-*-*-m-*-iso8859-1
courier.bold.0=-adobe-courier-bold-r-normal--*-%d-*-*-m-*-iso8859-1
courier.bolditalic.0=-adobe-courier-bold-o-normal--*-%d-*-*-m-*-iso8859-1
#

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
fontcharset.serif.0=sun.io.CharToByte8859_1
fontcharset.serif.1=sun.io.CharToByte8859_2
fontcharset.serif.2=sun.awt.motif.CharToByteX11Dingbats
fontcharset.serif.3=sun.awt.CharToByteSymbol


fontcharset.sansserif.0=sun.io.CharToByte8859_1
fontcharset.sansserif.1=sun.io.CharToByte8859_2
fontcharset.sansserif.2=sun.awt.motif.CharToByteX11Dingbats
fontcharset.sansserif.3=sun.awt.CharToByteSymbol


fontcharset.monospaced.0=sun.io.CharToByte8859_1
fontcharset.monospaced.1=sun.io.CharToByte8859_2
fontcharset.monospaced.2=sun.awt.motif.CharToByteX11Dingbats
fontcharset.monospaced.3=sun.awt.CharToByteSymbol


fontcharset.dialog.0=sun.io.CharToByte8859_1
fontcharset.dialog.1=sun.io.CharToByte8859_2
fontcharset.dialog.2=sun.awt.motif.CharToByteX11Dingbats
fontcharset.dialog.3=sun.awt.CharToByteSymbol


fontcharset.dialoginput.0=sun.io.CharToByte8859_1
fontcharset.dialoginput.1=sun.io.CharToByte8859_2
fontcharset.dialoginput.2=sun.awt.motif.CharToByteX11Dingbats
fontcharset.dialoginput.3=sun.awt.CharToByteSymbol


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
-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2

fontset.serif.italic=\
-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2

fontset.serif.bold=\
-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2

fontset.sansserif.italic=\
-hp-hp system-medium-r-normal--*-%d-*-*-p-*-iso8859-2

fontset.sansserif.bold=\
-hp-hp system-bold-r-normal--*-%d-*-*-p-*-iso8859-2
 
fontset.sansserif.plain=\
-hp-hp system-medium-r-normal--*-%d-*-*-p-*-iso8859-2

fontset.monospaced.italic=\
-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2
 
fontset.monospaced.bold=\
-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2
 
fontset.monospaced.plain=\
-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2
 
fontset.dialog.italic=\
-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2
 
fontset.dialog.bold=\
-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2
 
fontset.dialog.plain=\
-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2
 
fontset.dialoginput.italic=\
-hp-hp system-medium-r-normal--*-%d-*-*-p-*-iso8859-2
 
fontset.dialoginput.bold=\
-hp-hp system-bold-r-normal--*-%d-*-*-p-*-iso8859-2
 
fontset.dialoginput.plain=\
-hp-hp system-medium-r-normal--*-%d-*-*-p-*-iso8859-2

#
fontset.default=\
-hp-hp user-medium-r-normal--*-%d-*-*-m-*-iso8859-2
#
