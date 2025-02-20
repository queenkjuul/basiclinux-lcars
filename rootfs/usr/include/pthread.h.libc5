#ifndef _PTHREAD_H_
#define	_PTHREAD_H_

#include <features.h>

__BEGIN_DECLS

#ifndef _POSIX_THREADS
#define _POSIX_THREADS
#endif

#
#ifdef _MIT_POSIX_THREADS
# include <pthread/mit/pthread.h>
#else
/* These are dummy for Objective C. They should be replaced by a real
 * pthread package.
 * H.J.
 */
typedef void * pthread_mutex_t;
typedef void * pthread_key_t;
typedef void * pthread_t;

extern pthread_t	pthread_self __P (());
extern void *		pthread_getspecific __P ((pthread_key_t));

#endif

extern int __pthreaded;

/* Used to test if we are MT or not. */
#define threaded()	__pthreaded

__END_DECLS

#endif
