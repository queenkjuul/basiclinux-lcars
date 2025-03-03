slackwar: 	    slackware-9.0/ - contains glibc2 from slackware-9, see BasicLinux "library upgrade" docs

bbox-101.bz2:	  busybox-1.01.tar.bz2 - sources for version of busybox used in initrd

krnlsrc.bz2:	  linux-2.2.26.tar.bz2 - sources for kernel version used in BasicLinux
krnlcfg.txt:    linux-2.2.26.config  - kernel config for BasicLinux 3.5 (use to build your own kernel)

opera-85.bz2:   opera-8.54-20060330.1-static-qt.i386-en.tar.bz2 - statically linked Opera 8.54 browser for Linux; supported but untested

opera-75.gz:	  opera-7.54-static-qt-i386.tar.gz - statically linked Opera 7 browser for Linux; see BasicLinux docs (unsupported, untested)

opera-96.bz2    opera-9.64.gcc295-static-qt3.i386-nolocale.tar.bz2 - statically linked Opera 9.64 browser for Linux; 
                modified by keesan.freeshell.org.
                requires operalibs.tgz from the GitHub repo (on paper) but may work with slackware-9.0 misc-libs.tgz; 
                see docs in /contrib/keesan.freeshell.org.

No longer on the CD:

opera-71.bz2:   opera-7.11-20030515.1-static-qt.i386.tar.bz2 - statically linked Opera 7.11 browser for Linux; see BasicLinux docs (unsupported, untested)
uclibcrt.bz2:	  root_fs_i386.ext2.bz2 - raw disk image, bzip2'd, containing the uclibc toolchain used to build initrd busybox

*** ONLY THE CONTENTS OF slackwar ARE INSTALLABLE SLACKWARE .TGZ PACKAGES ***
*** THE REST ARE ONLY USING THE .TGZ EXTENSION AS ISO9660 DOES NOT ALLOW .TAR.GZ / .TAR.BZ2 EXTENSIONS ***