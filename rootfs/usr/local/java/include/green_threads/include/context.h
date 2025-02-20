/*
 * @(#)context.h	1.11 98/07/01
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
 * Generic include for Green contexts
 */

#ifndef _GREEN_CONTEXT_H_
#define _GREEN_CONTEXT_H_

#include "context_md.h"

#define CONTEXT(tid)    (&((tid)->mdcontext))

typedef struct  {
        stackp_t        base;
        uint_t          size;
} gstack_t;

void initContext(sys_thread_t *tid, unsigned long pc,
		 void (*death_func)(), unsigned long arg);
int allocateContextAndStack(sys_thread_t **tid, long stacksize);
void deleteContextAndStack(sys_thread_t *tid);
void cleanupPendingAlarm(sys_thread_t *tid);

#endif /* !_GREEN_CONTEXT_H_ */
