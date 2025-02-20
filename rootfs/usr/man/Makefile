# Do "make screen" first, if you want to protect already installed,
# more up-to-date manual pages than the ones included in this package.
# Do "make install" to copy the pages to their destination.
# Do "make gz" or "make bz2" first if you use compressed source pages.

# FHS requires /usr/share/man
MANDIR=/usr/man

GZIP=gzip -9
BZIP2=bzip2 -9

all: screen remove install

allgz: gz all

allbz: bz2 all

# Unfortunately, due to BSD brain damage codified by POSIX,
# code like "for i in dir/*; do STH; done" does not loop over
# all files in dir - indeed, when dir is empty it does STH
# once instead of zero times. David Balazic found that he
# lost his files and noticed the cause.
# [If we knew for sure this was using bash, we could set
#  allow_null_glob_expansion.]

screen:
	-mkdir not_installed
	files=man?/*; \
	if [ "$$files" != "man?/*" ]; then for i in $$files; do \
		if [ $(MANDIR)/$$i -nt $$i ]; then \
			diff -q $(MANDIR)/$$i $$i > /dev/null 2>&1; \
			if [ $$? != 0 ]; then mv $$i not_installed; fi; \
		fi; \
	done; fi

remove:
	rm -f $(MANDIR)/man2/modules.2 $(MANDIR)/man2/modules.2.gz
	rm -f $(MANDIR)/man3/exect.3 $(MANDIR)/man3/exect.3.gz
	files=man?/*; \
	if [ "$$files" != "man?/*" ]; then for i in $$files; do \
		rm -f $(MANDIR)/$$i $(MANDIR)/$$i.gz $(MANDIR)/$$i.bz2; \
	done; fi

gz:
	for i in man?; do $(GZIP) $$i/*; done

bz2:
	for i in man?; do $(BZIP2) $$i/*; done

install:
	for i in man?; do \
		install -d -m 755 $(MANDIR)/$$i; \
		install -m 644 $$i/* $(MANDIR)/$$i; \
	done
# someone might also want to look at /var/catman/cat2 or so ...
# a problem is that the location of cat pages varies a lot
