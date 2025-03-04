/*
 * @(#)schedule.h	1.14 98/07/01
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
 * Scheduling functions that other interfaces will need.  Generic to
 * Green threads package.
 */

#ifndef _GREEN_SCHEDULE_H_
#define _GREEN_SCHEDULE_H_

#include "queue.h"
#include "context.h"
#include "monitor_md.h"

/*
 * The rescheduling flag.  Set by an interrupt routine when
 * a (potentially) different thread should be chosen to run
 * instead of returning to the current thread.
 */
extern volatile int _needReschedule;

/*
 * The scheduling lock.  This is used to arbitrate access by the
 * asynchronous condition variable notification interface.
 *
 * SCHED_LOCK() and SCHED_UNLOCKED() used to be macros, but GCC
 * reordered instructions enough that they had to be changed to
 * functions to guarantee the causal order.
 */
extern int _scheduling_lock;
extern void _sched_lock();
extern void _sched_unlock();

#define SCHED_LOCK()	(_sched_lock())
#define SCHED_LOCKED()	(_scheduling_lock)
#define SCHED_UNLOCK()	(_sched_unlock())

/*
 * Switch to a new thread.
 */
#define YIELD() { \
    queueInsert(&runnable_queue, greenThreadSelf()); \
    yieldContext(CONTEXT(greenThreadSelf())); \
}

#endif /* !_GREEN_SCHEDULE_H_ */
