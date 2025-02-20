/*
 * @(#)sysmacros_md.h	1.17 98/07/01
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

#ifndef _SOLARIS_SYSMACROS_MD_H_
#define _SOLARIS_SYSMACROS_MD_H_

#include <stdio.h>

/*
 * Because these are used directly as function ptrs, just redefine the name
 */
#define sysMalloc	malloc
#define sysFree		free
#define sysCalloc	calloc
#define sysRealloc	realloc

/* A macro for sneaking into a sys_mon_t to get the owner sys_thread_t */
#define sysMonitorOwner(mid)   ((mid)->monitor_owner)

#ifdef DEBUG
extern void DumpThreads();
void panic (const char *, ...);
#define sysAssert(expression) {		\
    if (!(expression)) {		\
	fprintf(stderr,"\"%s\", line %d: assertion failure\n", __FILE__, __LINE__); \
	DumpThreads();			\
	panic("\"%s\", line %d: assertion failure\n", __FILE__, __LINE__); \
    }					\
}
#else
#define sysAssert(expression) 0
#endif

/*
 * Check whether an exception occurred.  This also gives us the oppor-
 * tunity to use the already-required exception check as a trap for other
 * system-specific conditions.
 */
#define sysCheckException(ee) \
	if (!exceptionOccurred(ee)) { \
	   continue; \
	}

/*
 * Case insensitive compare of ASCII strings
 */
#define sysStricmp(a, b)		strcasecmp(a, b)

/*
 * File system macros
 */
#define sysOpen(_path, _oflag, _mode)	open(_path, _oflag, _mode)
#define sysRead(_fd, _buf, _n)		read(_fd, _buf, _n)
#define sysWrite(_fd, _buf, _n)		write(_fd, _buf, _n)
#define sysClose(_fd)			close(_fd)
#define sysAccess(_path, _mode)		access(_path, _mode)
#define sysStat(_path, _buf)		stat(_path, _buf)
#define sysMkdir(_path, _mode)		mkdir(_path, _mode)
#define sysUnlink(_path)		unlink(_path)
#define sysIsAbsolute(_path)		(*(_path) == '/')
#define sysCloseDir(_dir)		closedir(_dir)
#define sysOpenDir(_path)		opendir(_path)
#define sysRmdir(_dir)                  rmdir(_dir)
#define sysNativePath(path)	        (path) 
#define sysSeek(fd, offset, whence)	lseek(fd, offset, whence)
#define sysRename(s, d)			rename(s, d)

/*
 * Set up thread-local storage for second order monitor cache.  The
 * number of words of thread-local storage must be a power of 2!
 */
#define SYS_TLS_MONCACHE 8 /* must be power of 2 */
#define sysCurrentCacheKey(tid) (tid->cacheKey)
#define sysLocalMonCache(tid, hash) (tid->monitorCache[hash])

/*
 * Solaris always runs in Total Store Order mode for Sparc and
 * Intel doesn't seem to support a weak consistency model for MP
 * so we define this to do nothing.
 */
#define sysStoreBarrier() 0

/*
 * Simple, fast recursive lock for the monitor cache.
 *
 * This is threads package specific, whereas sysmacros.h is not, but
 * could be simplified if sysmacros.h ever specializes.
 * 
 * The includes for threads package-specific files are ugly here because
 * this file goes into javah, which doesn't otherwise include from those
 * directories.
 *
 * Let's face it...we need threads package-specific sys include files.
 */
#ifndef NATIVE

#include "../green_threads/include/schedule.h"
#define sysCacheLockInit() 	/* A no-op */
#define sysCacheLock()		SCHED_LOCK()
#define sysCacheLocked()	SCHED_LOCKED()
#define sysCacheUnlock()	SCHED_UNLOCK()

/* Override the extern in sys_api.h with something faster */
#define sysThreadSelf()		greenThreadSelf()

#define sysMemoryFlush() 0
#define sysIsMP() 0

#else

#include "../native_threads/include/mutex_md.h"

typedef struct {
    mutex_t mutex;
    long entry_count;
    sys_thread_t *owner;
} cache_lock_t;

/*
 * We do leave the mutex locked across the whole cache lock to avoid
 * the extra unlock and lock that a smaller critical region would entail.
 */
extern cache_lock_t _moncache_lock;
#define sysCacheLockInit() {   mutexInit(&_moncache_lock.mutex);	\
			       _moncache_lock.entry_count = 0;		\
			       _moncache_lock.owner = 0;		\
			   }
#define sysCacheLock()     {   mutexLock(&_moncache_lock.mutex);	\
			       sysAssert(_moncache_lock.entry_count >= 0);\
			       if (_moncache_lock.entry_count++ == 0) {	\
				  _moncache_lock.owner = sysThreadSelf();\
			       }					\
			   }
/* Should not need locking: */
#define sysCacheLocked()   (_moncache_lock.owner == sysThreadSelf())
#define sysCacheUnlock()   {   sysAssert(_moncache_lock.entry_count > 0);\
			       if (--_moncache_lock.entry_count == 0) {	\
				  _moncache_lock.owner = 0;		\
			       }					\
			       mutexUnlock(&_moncache_lock.mutex);	\
			   }

#endif /* NATIVE */

#endif /*_SOLARIS_SYSMACROS_MD_H_*/
