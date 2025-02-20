/*
 * @(#)internal_md.h	1.10 98/07/01
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
 * Solaris-specific components of Green threads
 */

#ifndef _SOLARIS_INTERNAL_MD_H_
#define _SOLARIS_INTERNAL_MD_H_

#include <signal.h>

/*
 * Machine dependent info
 */
typedef struct {
    sigset_t intrLockOldMask;
    int intrLockCount;
} machdep_t;

#define MACHDEP(tid)    (&((tid)->machdep))

#endif /* !_SOLARIS_INTERNAL_MD_H_ */
