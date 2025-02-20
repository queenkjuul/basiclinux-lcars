/*
 * @(#)queue.h	1.8 98/07/01
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
 * A set of queue handling macros for processes.  Generic to Green
 * threads package.
 */

#ifndef _GREEN_QUEUE_H_
#define _GREEN_QUEUE_H_

#include "monitor_md.h"
#include "threads_md.h"

typedef sys_thread_t * queue_t;	/* linked through "waitq" field */

extern queue_t runnable_queue;

void queueInsert(queue_t *, sys_thread_t *);
int queueRemove(queue_t *, sys_thread_t *);
int queueSignal(sys_mon_t *, queue_t *);
void queueWait(sys_mon_t *, queue_t *);
void queueBroadcast(sys_mon_t *);
#define queueRemoveHead(q, t) (t=*(q), (t ? *(q)=(t)->waitq : 0), t)

#endif /* !_GREEN_QUEUE_H_ */
