/* ==== fd.h ============================================================
 * Copyright (c) 1993, 1994 by Chris Provenzano, proven@mit.edu
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
 * fd.h,v 1.2 1995/07/01 19:58:46 hjl Exp
 *
 * Description : Basic fd header.
 *
 *  1.00 93/08/14 proven
 *      -Started coding this file.
 *
 *	1.01 93/11/13 proven
 *		-The functions readv() and writev() added
 */

#ifndef _PTHREAD_MIT_FD_H
#define _PTHREAD_MIT_FD_H

#include <pthread/mit/sys/types.h>
#include <pthread/mit/machdep.h>
#include <pthread/mit/mutex.h>
#include <sys/cdefs.h>

/*
 * New pthread types.
 */
enum fd_type {
  FD_NT,		/* Not tested */
  FD_NIU,		/* Known to be not in use */
  FD_HALF_DUPLEX,	/* Files, and seeking devices */
  FD_FULL_DUPLEX,	/* pipes, sockets, drivers, ... */
  FD_TEST_HALF_DUPLEX,	/* Redo machdep_sys_fcntl */
  FD_TEST_FULL_DUPLEX	/* Redo machdep_sys_fcntl */
};


#define FD_READ		0x1
#define FD_WRITE	0x2
#define FD_RDWR		(FD_READ | FD_WRITE)

union fd_data {
  void *ptr;
  int i;
};

struct timespec;
struct iovec;
struct fd_ops {
  pthread_ssize_t (*write) __P((union fd_data, int, const void *,
                                size_t, struct timespec *));
  pthread_ssize_t (*read) __P((union fd_data, int, void *, size_t,
                               struct timespec *));
  int (*close) __P((union fd_data, int));
  int (*fcntl) __P ((union fd_data, int, ...));
  int (*writev) __P((union fd_data, int,
                     const struct iovec *,
                     int, struct timespec *));
  int (*readv) __P((union fd_data, int,
                    const struct iovec *,
                    int, struct timespec *));
  off_t	(*seek) __P ((union fd_data, int, off_t, int));
  int use_kfds;
};

struct fd_table_entry {
  struct pthread_queue	r_queue;
  struct pthread_queue	w_queue;
  struct pthread *r_owner;
  struct pthread *w_owner;
  pthread_mutex_t mutex;
  struct fd_table_entry	*next;
  struct fd_ops *ops;
  enum fd_type type;
  int r_lockcount;		/* Count for FILE read locks */
  int w_lockcount;		/* Count for FILE write locks */
  int count;

  /* data that needs to be passed to the type dependent fd */
  int flags;
  union fd_data fd;
};

/*
 * Globals
 */
#if defined(PTHREAD_KERNEL)

extern struct fd_table_entry **fd_table;
extern int dtablesize;

#endif

__BEGIN_DECLS

#if defined(PTHREAD_KERNEL)

extern int fd_init_entry __P((int));
extern int fd_check_entry __P((unsigned int));
extern void fd_init __P((void));
extern int fd_allocate __P((void));
extern void fd_basic_basic_unlock __P((struct fd_table_entry *, int));
extern void fd_basic_unlock __P((int, int));
extern void fd_unlock __P((int, int));
extern int fd_basic_lock __P((unsigned int, int,
                              pthread_mutex_t *, struct timespec *));
extern int fd_lock __P((unsigned int, int, struct timespec *));
extern struct fd_table_entry *fd_free __P((int));
extern ssize_t read_timedwait __P((int, void *, size_t, struct timespec *));
extern ssize_t readv_timedwait __P((int, const struct iovec *, int,
                                    struct timespec *));
extern ssize_t write_timedwait __P((int, const void *, size_t, 
                                    struct timespec *));
extern ssize_t writev_timedwait __P((int, const struct iovec *, int iovcnt,
                                     struct timespec *));

#endif

__END_DECLS

#endif /* _PTHREAD_MIT_FD_H */
