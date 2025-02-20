/*
 * @(#)prof_md.h	1.7 98/07/01
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
 * Solaris-dependent prof include
 */

#ifndef	_SOLARIS_PROF_MD_H_
#define	_SOLARIS_PROF_MD_H_

#if defined(__linux__)
#undef MARK(K)
#define MARK(K) {}          
#else
#include <prof.h>
#endif

#endif /* !_SOLARIS_PROF_MD_H_ */
