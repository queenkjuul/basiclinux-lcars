/* Copyright (C) 1991, 1992 Free Software Foundation, Inc.
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
 *      POSIX Standard: 5.6.6 Set File Access and Modification Times  <utime.h>
 */

#ifndef _UTIME_H
#define _UTIME_H

#include <features.h>
#include <sys/types.h>	/* I know - shouldn't do this, but .. */
#include <linux/utime.h>

__BEGIN_DECLS

extern int utime __P ((__const char *__filename,
		__const struct utimbuf *__utimebuf));

__END_DECLS

#endif	/* utime.h	*/
