/*
 * @(#)monitor_md.h	1.35 98/07/01
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
 * Monitor interface	10/25/94
 *
 * Private data structures and interfaces used in the monitor code.
 * This file is used to share declarations and such between the different
 * files implementing monitors.  It does not contain exported API.
 */

#ifndef	_GREEN_MONITOR_MD_H_
#define	_GREEN_MONITOR_MD_H_

#include "threads_md.h"

/*
 * Type definitions.
 */

/* The system-level monitor data structure */
struct sys_mon {
    /* Cache support */
    struct sys_mon	*pendingq;	/* Queue of interrupt info */

    long		entry_count;	/* Recursion depth */
    short		flags;		/* Various flags */

    /*
     * NOTE: SYS_MON_HAS_HANDLER is preserved across sysMonitorExit().
     * It is a permanent property of a monitor.  SYS_MON_HAS_HANDLER
     * must never be true for a cache monitor.
     */

#define SYS_MON_STICKY_NOTIFICATION	0x1
#define SYS_MON_PENDING_NOTIFICATION	0x2
#define SYS_MON_INVERTED_PRIORITY	0x4
#define SYS_MON_HAS_HANDLER		0x8 /* Interrupt handler registered */

    /* Thread currently executing in this monitor */
    sys_thread_t	*monitor_owner;

    /* Queue of threads trying to enter monitor */
    sys_thread_t	*monitor_waitq;

    /* Queue of threads suspended while in monitor */
    sys_thread_t	*suspend_waitq;

    /*
     * Condition Variable, otherwise know as the queue of threads
     * currently executing "wait()" inside a monitor
     */
    sys_thread_t	*condvar_waitq;

    sys_mon_t		*next_inversion;
};

typedef enum {
	ASYNC_REGISTER,
	ASYNC_UNREGISTER
} async_action_t;

/*
 * Macros
 */

#define SYS_MID_NULL ((sys_mon_t *) 0)

typedef enum {
	SYS_ASYNC_MON_ALARM = 1,
 	SYS_ASYNC_MON_IO,
 	SYS_ASYNC_MON_EVENT,
 	SYS_ASYNC_MON_CHILD,
 	SYS_ASYNC_MON_MAX
} async_mon_key_t;

#define SYS_ASYNC_MON_INPUT SYS_ASYNC_MON_IO
#define SYS_ASYNC_MON_OUTPUT SYS_ASYNC_MON_IO

/*
 * Support for the async part of async GC
 */
extern sys_mon_t *PendingNotifyQ;

int  monitorBroadcast(sys_mon_t *);
void monitorRemoveInversion(sys_mon_t *, sys_thread_t *);
void monitorAddInversion(sys_mon_t *);
int  monitorApplyInversion(sys_mon_t *);

sys_mon_t *asyncMon(async_mon_key_t);
int  asyncNotifier(async_action_t action, async_mon_key_t key);

#endif	/* _GREEN_MONITOR_MD_H_ */
