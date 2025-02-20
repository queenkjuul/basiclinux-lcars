/*
 * @(#)context_md.h	1.22 98/07/01
 *
 * Copyright 1995-1998 by Sun Microsystems, Inc.,
 * 901 San Antonio Road, Palo Alto, California, 94303, U.S.A.
 * All rights reserved.
 * 
 * This software is the confidential and proprietary information
 * of Sun Microsystems, Inc. ("Confidential Information").  You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Sun.
 */

/*
 * genunix32-dependent API
 */

#ifndef _GENUNIX32_CONTEXT_MD_H_
#define _GENUNIX32_CONTEXT_MD_H_

#include <errno.h>

#include <sys/types.h>
#include <sys/signal.h>
#include <setjmp.h>

typedef struct genunix_ucontext {
	sigjmp_buf	jmpbuf;
#if defined(__linux__) && defined(__i386__)
	char		floatbuf[108];
#elif defined(__powerpc__)  /* sbb: should this be __ppc__ ??? */
  /* linuxppc: PORT */
	unsigned int pc;
	unsigned int arg;
	unsigned int cr;
#endif
} genunix_ucontext_t;

/*
 * Routines that call getcontext have strange control flow graphs,
 * since a call to a routine that calls setcontext will eventually
 * return at the getcontext site, not the original call site.  This
 * utterly wrecks control flow analysis.
 */
#pragma unknown_control_flow(getcontext)

/*
 * A genunix context.  Everything else is on the stack.
 */
typedef struct {
    unsigned int unix_errno;
    genunix_ucontext_t ucontext;
} context_t;

/* Save state of the current content and call rescheduler */

void reschedule(void);

#if defined(__linux__) && defined(__i386__)
#define yieldContext(contextp) \
{ \
		char * fdata = (char *)contextp->ucontext.floatbuf; \
		__asm__ ("fsave %0"::"m" (*fdata)); \
		if (!sigsetjmp(contextp->ucontext.jmpbuf,-1)) { \
		  (contextp)->unix_errno = errno; \
		  reschedule(); \
		} \
  }
#elif defined(__linux__) && defined(__powerpc__)
/* linuxppc: PORT */
#define yieldContext(contextp) \
	{ \
		long cr; \
		__asm__ ("" : : : "13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"); \
		__asm__ ("mfcr %0" : "=r" (cr)); \
		contextp->ucontext.cr = cr; \
	        if (!sigsetjmp(contextp->ucontext.jmpbuf,1)) { \
	          (contextp)->unix_errno = errno; \
	          reschedule(); \
	        } \
	}
#elif defined(__linux__) && defined(__sparc__)
#define yieldContext(contextp) \
{ \
                if (!sigsetjmp(contextp->ucontext.jmpbuf,-1)) { \
                  (contextp)->unix_errno = errno; \
                  reschedule(); \
                } \
  }

#else
#define yieldContext(contextp) \
{ \
		if (!sigsetjmp(contextp->ucontext.jmpbuf,-1)) { \
		  (contextp)->unix_errno = errno; \
		  reschedule(); \
		} \
  }
#endif

/* switch to the new context */

#define switchContext(contextp) { \
   errno = (contextp)->unix_errno; \
   genunix_setcontext(&((contextp)->ucontext)); \
}


/*
 * Workaround for BUG 4007713/4026661/1262991:
 * create a private copy (fix) for x86 green threads getcontext
 * called green_getcontext to avoid the libc getcontext bug.
 * Furthermore, the green_getcontext code differs from the
 * libc behavior since it does not call __cerror if the system
 * call fails. Reference to __cerror was removed since its no
 * longer a global in Solaris 2.6 libc. This change in API should
 * be benign to the VM (we don't check for getcontext return code).
 */

#if defined(i386)

#if defined(__STDC__)

extern int green_getcontext(genunix_ucontext_t *);

#else

extern int green_getcontext();

#endif /* __STDC__ */

#define getcontext green_getcontext

#endif /* i386 */

#endif /* !_GENUNIX32_CONTEXT_MD_H_ */

