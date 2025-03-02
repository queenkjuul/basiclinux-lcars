/* Copyright (C) 1991, 1992, 1994 Free Software Foundation, Inc.
This file is part of the GNU C Library.

The GNU C Library is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public License as
published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version.

The GNU C Library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Library General Public
License along with the GNU C Library; see the file COPYING.LIB.  If
not, write to the, 1992 Free Software Foundation, Inc., 675 Mass Ave,
Cambridge, MA 02139, USA.  */

/*
 *	POSIX Standard: 6.5 File Control Operations	<fcntl.h>
 */

#ifndef _FCNTL_H
#define _FCNTL_H

#include <features.h>
#include <sys/types.h>
#include <gnu/types.h>
#include <linux/fcntl.h>

#ifndef FNDELAY
#define FNDELAY	O_NDELAY
#endif

__BEGIN_DECLS

/* Create and open FILE, with mode MODE.
   This takes an `int' MODE argument because that is
   what `mode_t' will be widened to.  */
extern int creat __P ((__const char * __filename, mode_t __mode));

/* Do the file control operation described by CMD on FD.
   The remaining arguments are interpreted depending on CMD.  */
extern int fcntl __P ((int __fildes,int __cmd, ...));
extern int __fcntl __P ((int __fildes,int __cmd, ...));

/* Open FILE and return a new file descriptor for it, or -1 on error.
   OFLAG determines the type of access used.  If O_CREAT is on OFLAG,
   the third argument is taken as a `mode_t', the mode of the created file.  */
extern int open __P ((__const char * __filename, int __flags, ...));
extern int __open __P ((__const char * __filename, int __flags, ...));

#if defined (__USE_MISC) && !defined (F_LOCK)
/* NOTE: These declarations also appear in <unistd.h>; be sure to keep both
   files consistent.  Some systems have them there and some here, and some
   software depends on the macros being defined without including both.  */

/* `lockf' is a simpler interface to the locking facilities of `fcntl'.
   LEN is always relative to the current file position.
   The CMD argument is one of the following.  */

#define F_ULOCK 0	/* Unlock a previously locked region.  */
#define F_LOCK  1	/* Lock a region for exclusive use.  */
#define F_TLOCK 2	/* Test and lock a region for exclusive use.  */
#define F_TEST  3	/* Test a region for other processes locks.  */

extern int lockf __P ((int __fd, int __cmd, __off_t __len));
#endif

__END_DECLS

#endif
