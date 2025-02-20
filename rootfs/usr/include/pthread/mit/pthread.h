/* ==== pthread.h ============================================================
 * Copyright (c) 1993, 1994 by Chris Provenzano, proven@mit.edu
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *  This product includes software developed by Chris Provenzano.
 * 4. The name of Chris Provenzano may not be used to endorse or promote 
 *	  products derived from this software without specific prior written
 *	  permission.
 *
 * THIS SOFTWARE IS PROVIDED BY CHRIS PROVENZANO ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL CHRIS PROVENZANO BE LIABLE FOR ANY 
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
 * SUCH DAMAGE.
 *
 * pthread.h,v 1.1 1995/06/11 00:25:59 hjl Exp
 *
 * Description : Basic pthread header.
 *
 *  1.00 93/07/20 proven
 *      -Started coding this file.
 */
 
#ifndef _PTHREAD_MIT_PTHREAD_H
#define _PTHREAD_MIT_PTHREAD_H

/* Make sure we get right errno. */
#include <errno.h>

#include <pthread/mit/types.h>

#include <pthread/mit/version.h>
#include <pthread/mit/machdep.h>
#include <pthread/mit/cleanup.h>
#include <pthread/mit/kernel.h>
#include <pthread/mit/prio_queue.h>
#include <pthread/mit/queue.h>
#include <pthread/mit/sleep.h>
#include <pthread/mit/mutex.h>
#include <pthread/mit/cond.h>
#include <pthread/mit/fd.h>
#include <pthread/mit/debug_out.h>

/* Requires mutex.h */
#include <pthread/mit/specific.h>

#include <pthread/mit/util.h>

/* More includes */
#include <pthread/mit/pthread_once.h>

/* More includes, that need size_t */
#include <pthread/mit/pthread_attr.h>

#ifdef PTHREAD_KERNEL

#include <signal.h> /* for sigset_t */

enum pthread_state {
#define __pthread_defstate(S,NAME) S,
#include "pthread/mit/state.def"
#undef __pthread_defstate

  /* enum lists aren't supposed to end with a comma, sigh */
  PS_STATE_MAX
};

#define PF_WAIT_EVENT 0x01
#define PF_DONE_EVENT 0x02

/* Put PANIC inside an expression that evaluates to non-void type, to
   make it easier to combine it in expressions.  */
#define DO_PANIC() (PANIC (), 0)
#define PANICIF(x) ((x) ? DO_PANIC () : 0)

#define SET_PF_DONE_EVENT(x)			\
( !(x->flags & PF_DONE_EVENT)			\
  ? ( (x->flags & PF_WAIT_EVENT)		\
	  ? (x->flags = PF_DONE_EVENT, OK)	\
	  : DO_PANIC ())			\
  : NOTOK )

#define SET_PF_WAIT_EVENT(x)				\
( PANICIF (x->flags & (PF_WAIT_EVENT | PF_DONE_EVENT)),	\
  (x->flags = PF_WAIT_EVENT), 0)
#define CLEAR_PF_DONE_EVENT(x)				\
( PANICIF (!(x->flags & PF_DONE_EVENT)),		\
  x->flags = 0 )

struct pthread_select_data {
  int nfds;
  fd_set readfds;
  fd_set writefds;
  fd_set exceptfds;
};

union pthread_wait_data {
  pthread_mutex_t *mutex;
  pthread_cond_t *cond;
  const sigset_t *sigwait; /* Waiting on a signal in sigwait */
  int fd;                  /* Used when thread waiting on fd */
  struct pthread_select_data *select_data;
};

struct pthread {
  struct machdep_pthread machdep_data;
  pthread_attr_t attr;

  /* Signal interface */
  sigset_t sigmask;
  sigset_t sigpending;
  int sigcount; /* Number of signals pending */

  /* Timeout time */
  struct timespec wakeup_time;

  /* Join queue for waiting threads */
  struct pthread_queue join_queue;

  /*
   * Thread implementations are just multiple queue type implemenations,
   * Below are the various link lists currently necessary
   * It is possible for a thread to be on multiple, or even all the
   * queues at once, much care must be taken during queue manipulation.
   *
   * The pthread structure must be locked before you can even look at
   * the link lists.
   */ 

  /*
   * ALL threads, in any state. 
   * Must lock kernel lock before manipulating.
   */
  struct pthread *pll;		

  /*
   * Standard link list for running threads, mutexes, etc ...
   * It can't be on both a running link list and a wait queue.
   * Must lock kernel lock before manipulating.
   */
  struct pthread *next;	
  union pthread_wait_data data;

  /*
   * Actual queue state and priority of thread.
   * (Note: "priority" is a reserved word in Concurrent C, please
   * don't use it.  --KR)
   */
  struct pthread_queue *queue;
  enum pthread_state state;
  char flags;
  char pthread_priority;

  /*
   * Sleep queue, this is different from the standard link list
   * because it is possible to be on both (pthread_cond_timedwait();
   * Must lock sleep mutex before manipulating
   */
  struct pthread *sll; /* For sleeping threads */

  /*
   * Data that doesn't need to be locked
   * Mostly it's because only the thread owning the data can manipulate it
   */
  void *ret;
  int error;
  int *error_p;
  const void **specific_data;
  int specific_data_count;

  /* Cleanup handlers Link List */
  struct pthread_cleanup *cleanup;
};

extern void pthread_sched_prevent (void);

#else /* not PTHREAD_KERNEL */

struct pthread;

#endif

typedef struct pthread *pthread_t;

/*
 * Globals
 */
#ifdef PTHREAD_KERNEL

extern struct pthread *pthread_run;
extern struct pthread *pthread_dead;
extern struct pthread *pthread_initial;
extern struct pthread *pthread_link_list;
extern pthread_attr_t pthread_attr_default;
extern volatile int fork_lock;

#endif

/*
 * New functions
 */

__BEGIN_DECLS

#if defined(DCE_COMPAT)

typedef	void *(*pthread_startroutine_t)(void *)
typedef  void *pthread_addr_t

int   pthread_create    __P((pthread_t *, pthread_attr_t,
                             pthread_startroutine_t, pthread_addr_t));
void  pthread_exit      __P((pthread_addr_t));
int   pthread_join      __P((pthread_t, pthread_addr_t *));

#else

void  pthread_init      __P((void));
int   pthread_create    __P((pthread_t *, const pthread_attr_t *,
                             void * (*start_routine)(void *), void *));
void  pthread_exit      __P((void *));
pthread_t pthread_self  __P((void));
int   pthread_equal     __P((pthread_t, pthread_t));
int   pthread_join      __P((pthread_t, void **));
int   pthread_detach    __P((pthread_t));
void  pthread_yield     __P((void));

int pthread_setschedparam __P((pthread_t pthread, int policy,
                               struct sched_param * param));
int pthread_getschedparam __P((pthread_t pthread, int * policy,
                               struct sched_param * param));

#endif

__END_DECLS

#endif /* _PTHREAD_MIT_PTHREAD_H */
