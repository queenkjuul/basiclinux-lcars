#ifndef __nl_typesh
#define __nl_typesh


/***********************************************************
Copyright 1990, by Alfalfa Software Incorporated, Cambridge, Massachusetts.

                        All Rights Reserved

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that Alfalfa's name not be used in
advertising or publicity pertaining to distribution of the software
without specific, written prior permission.

ALPHALPHA DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL
ALPHALPHA BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
SOFTWARE.

If you make any modifications, bugfixes or other changes to this software
we'd appreciate it if you could send a copy to us so we can keep things
up-to-date.  Many thanks.
				Kee Hinckley
				Alfalfa Software, Inc.
				267 Allston St., #3
				Cambridge, MA 02139  USA
				nazgul@alfalfa.com
    
******************************************************************/

#include <features.h>

#ifdef __SVR4_I386_ABI_L1__
#define	NL_SETD	1
typedef	void*	nl_catd;
/* XXX The SVR4 ABI defines nl_item as type int, declared in <nl_types.h>,
   but the Linux C library declares it as an enum in <langinfo.h>. */
#else
#define	NL_SETD	0
typedef	long	nl_catd;
#endif


/* These should be publicly available */

extern nl_catd	catopen		__P((__const char *, int));
extern char	*catgets	__P((nl_catd, int, int, __const char *));
extern int	catclose	__P((nl_catd));

#define MCLoadBySet	0	/* Load entire sets as they are used */
#define MCLoadAll	1	/* Load entire DB on catopen */

extern char	*MCAppPath;	/* Additional search path for strings (appended) */

#ifdef _LIBC

#include "nls_libc.h"
extern nl_catd _libc_cat;
void libc_nls_init(void);

#endif

#endif
