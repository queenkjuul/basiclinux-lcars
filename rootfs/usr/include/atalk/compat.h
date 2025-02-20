/*
 * Copyright (c) 1996 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 *
 * NOTE: SunOS 4 and ultrix are pretty much the only reason why there
 * are checks for EINTR everywhere. 
 */

#include <sys/cdefs.h>

# ifdef __svr4__
/*
 * SunOS 5 (solaris) has SA_RESTART, but no SA_INTERRUPT.
 */
#ifndef SA_INTERRUPT
#define SA_INTERRUPT	0
#endif

#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>

extern int flock __P((int, int));
extern int inet_aton __P((const char *, struct in_addr *));
# else __svr4__

#ifdef sun
/*
 * SunOS 4 has SA_INTERRUPT, but no SA_RESTART.
 */
#ifndef SA_RESTART
#define SA_RESTART	0
#endif
#endif sun

# endif __svr4__

#ifdef linux
/*
 * Linux has SA_RESTART, but no SA_INTERRUPT.  Note that the documentation
 * seems to be wrong on several counts.  First, SA_ONESHOT is not the default,
 * and second, SA_RESTART does what you'd expect (the same as svr4) and has
 * nothing to do with SA_ONESHOT.
 */
#ifndef SA_INTERRUPT
#define SA_INTERRUPT	0
#endif SA_INTERRUPT
#endif linux

#ifdef ultrix
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>

/*
 * Here's the really confusing one...  Under Ultrix, sigaction() works just
 * like sigvec(), except that SV_INTERRUPT is always set.  Hence, there is
 * no SA_INTERRUPT flag.  Unfortunately, there's also no SA_RESTART, so
 * there's no way to suppress the interrupt.  Sigh.
 */
#ifndef SA_INTERRUPT
#define SA_INTERRUPT	0
#endif
#ifndef SA_RESTART
#define SA_RESTART	0
#endif

extern char *strdup __P((const char *));
extern int inet_aton __P((const char *, struct in_addr *));
#endif ultrix

#ifdef BSD4_4
#ifndef SA_INTERRUPT
#define SA_INTERRUPT	0
#endif
#endif /* BSD4_4 */
