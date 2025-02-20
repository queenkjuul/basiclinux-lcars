#ifndef _SYSCALL_H
#define _SYSCALL_H

#include <features.h>
#include <sys/syscall.h>
#include <errno.h>

#ifndef __MAX_ERRNO
#define __MAX_ERRNO 4096
#endif

/* In case of returning a memory address, negative values may
 * not mean error.
 */
#ifdef __CHECK_RETURN_ADDR
#define __check_errno(__res)	\
	((__res) >= 0 || (__res) < -__MAX_ERRNO)
#else
#define __check_errno(__res)	((__res) >= 0)
#endif

__BEGIN_DECLS

extern	int syscall __P ((int __number, ...));

__END_DECLS

#if defined(__i386__)
# include <i386/syscall.h>
#elif defined (__mc68000__)
# include <m68k/syscall.h>
#else
# error architecture not supported by Linux C library
#endif

#endif
