/*
 * @(#)threads_md.h	1.31 98/07/01
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
 * Green threads: private interface.  Although this file fits in
 * the machine-specific directory given our current abstractions,
 * it is actually generic to all Green threads implementations.
 * Machine-specific stuff should appear in the machdep_t structure
 * defined in internal_md.h.
 */

#ifndef _GREEN_THREADS_MD_H_
#define _GREEN_THREADS_MD_H_

#include "internal_md.h"	/* Machine-specific information */
#include "context_md.h"
#include "timeval_md.h"

/*
 * Forward definition of machine dependent monitor struct
 */
struct sys_mon ;

/*
 * Machine dependent info in a sys_thread_t: Keep these values in
 * sync with the string array used by sysThreadDumpInfo() in threads_md.c!
 */
typedef enum {
    FIRST_THREAD_STATE,
    RUNNABLE = FIRST_THREAD_STATE,
    SUSPENDED,
    MONITOR_WAIT,
    CONDVAR_WAIT,
    MONITOR_SUSPENDED,
    NUM_THREAD_STATES
} thread_state_t;

struct sys_thread {
    void    *cookie;	       		/* Opaque cookie - a backpointer */
    					/* to JavaThread object */

    sys_thread_t *next;			/* Pointer to next thread in list */
    					/* of all threads. */
    /*
     * Fields below this point may change on a per-architecture basis
     * depending on how much work is needed to present the sysThread
     * model on any given thread implementation.
     */

    thread_state_t state;		/* Thread state */
    sys_thread_t *waitq;		/* Waiting queue */

    /* Thread status flags */
    unsigned int full_switch:1;
    unsigned int system_thread:1;
    unsigned int primordial_thread:1;
    unsigned int pending_suspend:1;
    unsigned int interrupted:1;
    unsigned int vmsuspended:2;
    unsigned int :0;

    /* Thread stack information */
    stackp_t stack_base; /* The logical stack base, not lowest address! */
    long     stack_size; /* Needed by context code */

    /* Machine-dependent (mapped) priority */
    int	     priority;

    /* Monitor specific.

       Every monitor keeps track of the number of times it is
       entered.  When that count goes to 0, the monitor can be
       freed up.  But each thread has its own entry count on a
       particular monitor, because multiple threads can be using a
       single monitor (as one does a wait, another enters, etc.).
       Each thread can only be waiting in exactly one monitor.
       That monitor waited on is saved in mon_wait, and the value
       of the monitor's entry_count when the wait was performed is
       saved in monitor_entry_count.  That is restored into the
       monitor when this waiting thread is notified. */

    int monitor_entry_count;		/* For recursive monitor entry */
    sys_mon_t *mon_wait;		/* MONITOR_WAIT or CONDVAR_WAIT'ing */

    int oldPriority;			/* For priority inversion */
    sys_mon_t *inversion_queue;

    /* alarm-specific */
    sys_thread_t *timeoutQ;		/* CV wait timeout queue */
    timeval_t timeout;			/* CV wait timeout value */

    context_t mdcontext;		/* Machine context */
    machdep_t machdep;			/* Machine dependent info */

    /* R/Y/G lowmem detection and suspension-specific */
    int vmoldPriority;			/* From before vmsuspended to -1 */

    unsigned int cacheKey;
    void * monitorCache[SYS_TLS_MONCACHE];
};

#define SYS_THREAD_NULL        	((sys_thread_t *) 0)

extern sys_thread_t *_CurrentThread;
extern void setCurrentThread(sys_thread_t *);
#define greenThreadSelf()  (_CurrentThread)

extern void threadWakeup(sys_thread_t *);
extern int threadSetSchedulingPriority(sys_thread_t *, int priority);

#ifndef MAX
#define MAX(x, y)       ((x) > (y) ? (x) : (y))
#endif

#define INVERSION_PRIORITY(tid) \
    MAX((tid)->oldPriority, (tid)->inversion_queue->monitor_waitq->priority)

#endif /* !_GREEN_THREADS_MD_H_ */
