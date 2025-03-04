/*
 * @(#)jmath_md.h	1.6 98/07/01
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

#if defined(__solaris__)
#include <ieeefp.h>
#endif

#if defined(__powerpc__)
/* linuxppc: PORT (addition of working modulo code) */
/* sbb: I'm being cautious right now and not mainlining the jdk_modulo
 * functions until I've had some experience with them. */
#include "jdk_modulo.h"
#define DREM(a,b) jdk_fmod(a,b)
#define IEEEREM(a,b) jdk_remainder(a,b)
#else
#define DREM(a,b) fmod(a,b)
#if defined(__solaris__)
#define IEEEREM(a,b) remainder(a,b)
#else
#define IEEEREM(a,b) fmod(a,b)
#endif
#endif
