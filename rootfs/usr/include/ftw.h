/* Copyright (C) 1992 Free Software Foundation, Inc.
This file is part of the GNU C Library.
Contributed by Ian Lance Taylor (ian@airs.com).

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
not, write to the Free Software Foundation, Inc., 675 Mass Ave,
Cambridge, MA 02139, USA.  */

/*
 *	SVID ftw.h
 */

#ifndef _FTW_H

#define	_FTW_H	1
#include <features.h>

#ifdef __linux__
#include <sys/stat.h>
#else
#include <statbuf.h>
#endif

/* The FLAG argument to the user function passed to ftw.  */
#define FTW_F	0		/* Regular file.  */
#define FTW_D	1		/* Directory.  */
#define FTW_DNR	2		/* Unreadable directory.  */
#define FTW_NS	3		/* Unstatable file.  */

#ifdef __SVR4_I386_ABI_L1__
#define FTW_SL		 4
#define FTW_DP		 6
#define FTW_SLN		 7

#define FTW_PHYS	(1<<0)
#define FTW_MOUNT	(1<<1)
#define	FTW_CHDIR	(1<<2)
#define FTW_DEPTH	(1<<3)

struct FTW {
    int quit;
    int base;
    int level;
};

#define	FTW_SKD		(1<<0)
#define FTW_FOLLOW	(1<<1)
#define FTW_PRUNE	(1<<2)

#endif /* __SVR4_I386_ABI_L1__ */

__BEGIN_DECLS

typedef int (*__ftw_func_t) __P ((__const char *__file,
		 struct stat *__status, int __flag));

/* Call a function on every element in a directory tree.  */
extern int ftw __P ((__const char *__dir, __ftw_func_t __func,
		 int __descriptors));

__END_DECLS

#endif	/* ftw.h */
