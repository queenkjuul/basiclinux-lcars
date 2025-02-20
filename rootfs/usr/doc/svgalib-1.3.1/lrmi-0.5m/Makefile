CFLAGS = -g -Wall

sources = lrmi.c
objects = lrmi.o
all = vbetest mode3

%.o: %.c
	$(CC) -c $(CPPFLAGS) $(CFLAGS) -o $@ $<

all: $(all)

vbetest: vbetest.c lrmi.o
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $^

mode3: mode3.c lrmi.o
	$(CC) $(CFLAGS) -o $@ $^

install: mode3
	install mode3 /sbin

.PHONY: clean
clean:
	rm -f $(objects) $(all) core

.PHONY: distclean
distclean: clean
	rm -f .depend

.PHONY: depend
depend: $(sources)
	-$(CC) -M $(CPPFLAGS) $^ >.depend
