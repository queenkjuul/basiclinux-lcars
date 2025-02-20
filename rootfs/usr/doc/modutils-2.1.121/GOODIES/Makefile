CFLAGS = -O2 -pipe -fomit-frame-pointer -Wall $(DEBUG) $(XTRA)

first: kdsound

install: kdsound
	install -m 0700 -o root kdsound /sbin/kdsound
	install -m 0700 -o root do_sound /sbin/do_sound
