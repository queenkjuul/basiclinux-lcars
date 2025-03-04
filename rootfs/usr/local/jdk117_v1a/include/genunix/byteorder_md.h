/*
 * @(#)byteorder_md.h	1.6 98/07/01
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
 * Solaris-dependent byte order include
 */

#ifndef	_SOLARIS_BYTE_MD_H_
#define	_SOLARIS_BYTE_MD_H_

/* linux: PORT (location of byteorder.h) */
#ifdef __linux__
#include <asm/byteorder.h>
#else
#include <sys/byteorder.h>
#endif

#endif	/* !_SOLARIS_BYTE_MD_H_ */
