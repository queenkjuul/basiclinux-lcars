/*
 * @(#)timeval_md.h	1.11 98/07/01
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

#ifndef	_SOLARIS_TIMEVAL_H_
#define	_SOLARIS_TIMEVAL_H_

#ifdef __GLIBC__
#define __need_timeval
#include <timebits.h>
typedef struct timeval timeval_t;
#else
typedef struct {
	long tv_sec;		/* seconds */
	long tv_usec;		/* microseconds (NOT milliseconds) */
} timeval_t;
#endif /* __GLIBC__ */

#endif	/* !_SOLARIS_TIMEVAL_H_ */
