#ifndef _POSIX_OPT_H
#define _POSIX_OPT_H

/* only root can do a chown (I think..) */
#define _POSIX_CHOWN_RESTRICTED	1

/* no pathname truncation (but see in kernel) */
#define _POSIX_NO_TRUNC		1

/* character to disable things like ^C */
#define _POSIX_VDISABLE		'\0'

#define _POSIX_JOB_CONTROL	1

/* Implemented, for whatever good it is */
#define _POSIX_SAVED_IDS	1 

#if defined(_POSIX_THREAD_PRIO_INHERIT) || \
	defined(_POSIX_THREAD_PRIO_PROTECT)
#ifndef _POSIX_THREAD_PRIORITY_SCHEDULING
#define _POSIX_THREAD_PRIORITY_SCHEDULING 1
#endif
#endif

#ifdef _POSIX_THREAD_PRIORITY_SCHEDULING
#ifndef _POSIX_THREADS
#define _POSIX_THREADS	1
#endif
#endif

#ifdef _MIT_POSIX_THREADS
#ifndef _POSIX_THREADS
#define _POSIX_THREADS	1
#endif
#endif

#ifdef _POSIX_THREADS
#ifndef _POSIX_THREAD_SAFE_FUNCTIONS
#define _POSIX_THREAD_SAFE_FUNCTIONS	1
#endif
#endif

/* portability specification for POSIX.1b extensions */

#define _POSIX_FSYNC			1
#define _POSIX_MAPPED_FILES		1
#define _POSIX_MEMLOCK			1
#define _POSIX_MEMLOCK_RANGE		1
#define _POSIX_MEMORY_PROTECTION	1
#define _POSIX_PRIORITY_SCHEDULING	1

#endif
