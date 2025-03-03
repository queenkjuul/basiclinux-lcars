Put source code for jpeg png zlib into the ghostscript directory.
(Tiff not needed, can use the so and h files elsewhere).

make clean

./configure --enable-compiled-inits [makes it all one file]
            --without-x
	    --without-ijs
	    --without-jasper
	    --with-jbig2dec         [needed to read some pdf files]
	    --with-gs=gs-8.54-small [prename the file, optional]

edit Makefile to delete most of the printers but keep:
bmp256 and pbmraw (for svp) and pbm ppm ppmraw pgm pgmraw for pstopnm

keep all the deskjet and any relevant ljet (not ljet 3, yes ljet2p,
ljet4) and the pdf and ps write devices (to convert between ps/pdf)

I deleted also uniprint, png, jpeg, etc.  Can use netpbm via pnm(raw).

Don't know how to include lvga256.

make (wait 5-10 minutes)

NO need to install, you only need the gs file itself, fonts and 
the Gsfonts.gs (list of fonts).  Can also add pdf2ps ps2pdf and other
scripts (not .bat) from lib/ and files from doc/ manually.
