/* ==== posix.h ============================================================
 * Copyright (c) 1993, 1994 by Chris Provenzano, proven@athena.mit.edu	
 *
 * $Id: posix.h,v 1.1 1995/06/11 00:25:58 hjl Exp $
 *
 * Description : Convert a Linux-1.0 system to a more or less POSIX system.
 *				 Mostly POSIX already
 */
 
#ifndef _PTHREAD_MIT_POSIX_H
#define _PTHREAD_MIT_POSIX_H

#include <sys/cdefs.h>

/* Make sure we have size_t defined */
#include <pthread/mit/types.h>

#define __INLINE	extern inline
/*
 * OK now do stuff to make the code compile. 
 * Every OS has its own prototypes for each function
 */
#ifdef malloc
#undef malloc
#endif

#ifdef free
#undef free
#endif

#endif /* _PTHREAD_MIT_POSIX_H */
