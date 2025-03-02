/* ==== mutex.h ============================================================
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
 * mutex.h,v 1.3 1995/07/01 19:58:47 hjl Exp
 *
 * Description : mutex header.
 *
 *  1.00 93/07/20 proven
 *      -Started coding this file.
 */
 
#ifndef _PTHREAD_MIT_MUTEX_H
#define _PTHREAD_MIT_MUTEX_H

#include <pthread/mit/queue.h>

/*
 * New mutex structures
 */
enum pthread_mutextype {
  MUTEX_TYPE_STATIC_FAST,
  MUTEX_TYPE_FAST,
  MUTEX_TYPE_COUNTING_FAST, /* Recursive */
  MUTEX_TYPE_METERED,
  MUTEX_TYPE_DEBUG,         /* This will have lots of options */
  MUTEX_TYPE_MAX
};

#define PTHREAD_MUTEXTYPE_FAST      0x01
#define PTHREAD_MUTEXTYPE_DEBUG     0x04
#define PTHREAD_MUTEXTYPE_RECURSIVE 0x02

union pthread_mutex_data {
  void *m_ptr;
  int m_count;
};

typedef struct pthread_mutex {
  enum pthread_mutextype m_type;
  struct pthread_queue m_queue;
  struct pthread *m_owner;
  semaphore m_lock;	
  union pthread_mutex_data m_data;
  long m_flags;
} pthread_mutex_t;

typedef struct pthread_mutex_attr {
  enum pthread_mutextype m_type;
  long m_flags;
} pthread_mutexattr_t;

/*
 * Flags for mutexes.
 */
#define MUTEX_FLAGS_PRIVATE 0x01
#define MUTEX_FLAGS_INITED  0x02
#define MUTEX_FLAGS_BUSY    0x04

/*
 * Static mutex initialization values.
 */
#define PTHREAD_MUTEX_INITIALIZER \
{ MUTEX_TYPE_STATIC_FAST, PTHREAD_QUEUE_INITIALIZER, \
    NULL, SEMAPHORE_CLEAR, { NULL }, MUTEX_FLAGS_INITED }

/*
 * New functions
 */

__BEGIN_DECLS

int pthread_mutex_init __P((pthread_mutex_t *, const pthread_mutexattr_t *));
int pthread_mutex_lock __P((pthread_mutex_t *));
int pthread_mutex_unlock __P((pthread_mutex_t *));
int pthread_mutex_trylock __P((pthread_mutex_t *));
int pthread_mutex_destroy __P((pthread_mutex_t *));

pthread_mutex_t *__pthread_mutex_malloc __P((const pthread_mutexattr_t *));
void __pthread_mutex_free __P((pthread_mutex_t *));

__END_DECLS
	
#endif /* _PTHREAD_MIT_MUTEX_H */
