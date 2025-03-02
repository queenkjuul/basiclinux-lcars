/* ==== pthread_once.h ========================================================
 * Copyright (c) 1993 by Chris Provenzano, proven@mit.edu
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *  This product includes software developed by Chris Provenzano.
 * 4. The name of Chris Provenzano may not be used to endorse or promote 
 *	  products derived from this software without specific prior written
 *	  permission.
 *
 * THIS SOFTWARE IS PROVIDED BY CHRIS PROVENZANO ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL CHRIS PROVENZANO BE LIABLE FOR ANY 
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
 * SUCH DAMAGE.
 *
 * pthread_once.h,v 1.2 1995/07/01 19:58:50 hjl Exp
 *
 * Description : mutex header.
 *
 *  1.00 93/12/12 proven
 *      -Started coding this file.
 */
 
#ifndef _PTHREAD_MIT_PTHREAD_ONCE_H
#define _PTHREAD_MIT_PTHREAD_ONCE_H

#include <pthread/mit/pthread.h>

/* New pthread_once structures */
typedef	struct pthread_once {
  int state;
  pthread_mutex_t mutex;
} pthread_once_t;

/* Static pthread_once_t initialization value. */
#define PTHREAD_NEEDS_INIT 0
#define PTHREAD_DONE_INIT  1
#define PTHREAD_ONCE_INIT  { PTHREAD_NEEDS_INIT, PTHREAD_MUTEX_INITIALIZER }

/* New functions */

__BEGIN_DECLS

int pthread_once __P((pthread_once_t *, void (*init_routine)(void)));

__END_DECLS
	
#endif /* _PTHREAD_MIT_PTHREAD_ONCE_H */
