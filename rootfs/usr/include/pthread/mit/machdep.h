/* ==== machdep.h ============================================================
 * Copyright (c) 1993 Chris Provenzano, proven@athena.mit.edu
 *
 * machdep.h,v 1.2 1995/09/13 02:20:26 hjl Exp
 */

#ifndef _PTHREAD_MIT_MACHDEP_H
#define _PTHREAD_MIT_MACHDEP_H

#include <unistd.h>
#include <setjmp.h>
#include <sys/uio.h>
#include <sys/time.h>
#include <sys/socket.h>

/*
 * The first machine dependent functions are the SEMAPHORES
 * needing the test and set instruction.
 */
#define SEMAPHORE_CLEAR 0
#define SEMAPHORE_SET   1

#ifdef __i386__
#define SEMAPHORE_TEST_AND_SET(lock)    \
({					\
volatile long temp = SEMAPHORE_SET;     \
					\
__asm__("xchgl %0,(%2)"                 \
        :"=r" (temp)                    \
        :"0" (temp),"r" (lock));        \
temp;                                   \
})
#endif

#ifdef __mc68000__
#define SEMAPHORE_TEST_AND_SET(lock)    \
({					\
long temp = SEMAPHORE_SET;		\
					\
__asm__ __volatile__			\
	("movel %2@,%0\n\t"		\
	 "1:\t"				\
	 "casl %0,%1,%2@\n\t"		\
	 "jne 1b"			\
	 : "=&d" (temp)			\
	 : "d" (temp), "a" (lock));	\
temp;                                   \
})
#endif

#define SEMAPHORE_RESET(lock) *lock = SEMAPHORE_CLEAR

/*
 * New types
 */
typedef long semaphore;

#define SIGMAX 31

/*
 * New Strutures
 */
struct machdep_pthread {
  void *(*start_routine)(void *);
  void *start_argument;
  void *machdep_stack;
  struct itimerval machdep_timer;
  jmp_buf machdep_state;
#ifdef __i386__
  char machdep_float_state[108];
#endif
#ifdef __mc68000__
  char machdep_float_state[8*12];
#endif
};

/*
 * Static machdep_pthread initialization values.
 * For initial thread only.
 */
#define MACHDEP_PTHREAD_INIT {NULL, NULL, NULL, {{0,0}, {0,100000}}}

/*
 * Minimum stack size
 */
#define PTHREAD_STACK_MIN 1024

/*
 * sigset_t macros
 */
#define	SIG_ANY(sig) (sig)

/*
 * Some fd flag defines that are necessary to distinguish between posix
 * behavior and bsd4.3 behavior.
 */
#define __FD_NONBLOCK O_NONBLOCK

/*
 * New functions
 */

__BEGIN_DECLS

#if defined(PTHREAD_KERNEL)

struct pthread;

int machdep_save_state __P((void));
void machdep_restore_state __P((void));
void machdep_save_float_state __P((struct pthread *));
void machdep_restore_float_state __P((void));
void machdep_set_thread_timer __P((struct machdep_pthread *));
void machdep_unset_thread_timer __P((struct machdep_pthread *));
void *machdep_pthread_cleanup __P((struct machdep_pthread *));
void machdep_pthread_start __P((void));
void machdep_pthread_create __P((struct machdep_pthread *,
                                 void * (*start_routine)(void *),
                                 void *, long, void *, long));
int machdep_sys_socket __P((int, int, int));
int machdep_sys_accept __P((int, struct sockaddr *, int *));
int machdep_sys_bind __P((int, const struct sockaddr *, int));
int machdep_sys_connect __P((int, const struct sockaddr *, int));
int machdep_sys_listen __P((int, int));
int machdep_sys_shutdown __P((int, int));
int machdep_sys_getsockopt __P((int, int, int, char *, int *));
int machdep_sys_setsockopt __P((int, int, int, char *, int));
int machdep_sys_getpeername __P((int, struct sockaddr *, int *));
int machdep_sys_send __P((int, char *, int, int));
int machdep_sys_sendto __P((int, char *, int, int, struct sockaddr *, int));
int machdep_sys_recv __P((int, char *, int, int));
int machdep_sys_recvfrom __P((int, char *, int, int,
                              struct sockaddr *, int *));
int machdep_sys_read __P((int, char *, size_t));
int machdep_sys_readv __P((int, struct iovec *, int));
int machdep_sys_sendmsg __P((int, char *, int));
int machdep_sys_write __P((int, char *, size_t));
int machdep_sys_writev __P((int, struct iovec *, int));
int machdep_sys_recvmsg __P((int, char *, int));
int machdep_sys_getdirentries __P((int, char *, int, int *));
int machdep_sys_wait3 __P((int *, int, int *));
int machdep_sys_wait4 __P((int, int *, int, int *));
int machdep_sys_waitpid __P((int, int *, int));
int machdep_sys_getdtablesize __P((void));

#endif

__END_DECLS

#endif /* _PTHREAD_MIT_MACHDEP_H */
