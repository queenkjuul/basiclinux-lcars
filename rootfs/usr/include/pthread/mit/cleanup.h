/* ==== cleanup.h ============================================================
 * Copyright (c) 1994 by Chris Provenzano, proven@mit.edu
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
 * cleanup.h,v 1.2 1995/07/01 19:58:46 hjl Exp
 *
 * Description : cleanup header.
 *
 *  1.20 94/02/13 proven
 *      -Started coding this file.
 */

#ifndef _PTHREAD_MIT_CLEANUP_H
#define _PTHREAD_MIT_CLEANUP_H

#include <sys/cdefs.h>

/*
 * New cleanup structures
 */
struct pthread_cleanup {
  struct pthread_cleanup *next;
  void (*routine)__P((void *));
  void *routine_arg;		
};

/*
 * New functions
 */

__BEGIN_DECLS

extern int
pthread_cleanup_push __P((void (*routine)(void *), void *routine_arg));

extern void pthread_cleanup_pop __P((int execute));

__END_DECLS
	
#endif /* _PTHREAD_MIT_CLEANUP_H */
