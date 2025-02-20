/* Prototypes and definition for malloc implementation.
   Copyright (C) 1996, 1997 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

#ifndef _MALLOC_H
#define _MALLOC_H	1

#include <features.h>

#ifndef	NULL
#ifdef __cplusplus
#define	NULL	0
#else
#define	NULL	((void *) 0)
#endif
#endif

#ifdef	__STDC__
#include <stddef.h>
#else
#undef	size_t
#define	size_t		unsigned int
#undef	ptrdiff_t
#define	ptrdiff_t	int
#endif

extern int __libc_malloc_initialized;

/* For backward compatibilities and X11R5 */
#if (defined(MALLOC_0_RETURNS_NULL) || defined(NO_FIX_MALLOC)) \
	&& !defined(__MALLOC_0_RETURNS_NULL)
#define __MALLOC_0_RETURNS_NULL
#endif
 
__BEGIN_DECLS

/* We have changed malloc () to take malloc (0). */
#if 0 && defined(_STDLIB_H) && !defined(__MALLOC_0_RETURNS_NULL)
/* Allocate SIZE bytes of memory.  */
static void * malloc __P ((size_t __size));
/* Allocate NMEMB elements of SIZE bytes each, all initialized to 0.  */
static void * calloc __P ((size_t __nmemb, size_t __size));
#else
/* Allocate SIZE bytes of memory.  */
extern __ptr_t malloc __P ((size_t __size));
/* Allocate NMEMB elements of SIZE bytes each, all initialized to 0.  */
extern __ptr_t calloc __P ((size_t __nmemb, size_t __size));
#endif
/* Re-allocate the previously allocated block
   in __ptr_t, making the new block SIZE bytes long.  */
extern __ptr_t realloc __P ((__ptr_t __ptr, size_t __size));
/* Free a block allocated by `malloc', `realloc' or `calloc'.  */
extern void free __P ((__ptr_t __ptr));

/* Allocate SIZE bytes allocated to ALIGNMENT bytes.  */
extern __ptr_t memalign __P ((size_t __alignment, size_t __size));

/* Allocate SIZE bytes on a page boundary.  */
extern __ptr_t valloc __P ((size_t __size));

/* Underlying allocation function; successive calls should
   return contiguous pieces of memory.  */
extern __ptr_t (*__morecore) __P ((ptrdiff_t __size));

/* Default value of `__morecore'.  */
extern __ptr_t __default_morecore __P ((ptrdiff_t __size));
extern __ptr_t __default_morecore_init __P ((ptrdiff_t __size));

/* Nonzero if `malloc' has been called and done its initialization.  */
extern int __malloc_initialized;

/* Hooks for debugging versions.  */
extern void (*__free_hook) __P ((__ptr_t __ptr));
extern __ptr_t (*__malloc_hook) __P ((size_t __size));
extern __ptr_t (*__realloc_hook) __P ((__ptr_t __ptr, size_t __size));

/* Activate a standard collection of debugging hooks.  */
extern void mcheck __P ((void (*__func)(void)));

/* Activate a standard collection of tracing hooks.  */
extern void mtrace __P ((void));

/* Statistics available to the user.  */
struct mstats
  {
    size_t bytes_total;		/* Total size of the heap. */
    size_t chunks_used;		/* Chunks allocated by the user. */
    size_t bytes_used;		/* Byte total of user-allocated chunks. */
    size_t chunks_free;		/* Chunks in the free list. */
    size_t bytes_free;		/* Byte total of chunks in the free list. */
  };

/* Pick up the current statistics. */
extern struct mstats mstats __P ((void));

/* These are for malloc from Doug Lea, dl@cs.oswego.edu. */
extern int malloc_trim __P((size_t __pad));
extern size_t malloc_usable_size __P((void * __mem));
extern void malloc_stats __P((void));

struct mallinfo
{
  int arena;    /* total space allocated from system */
  int ordblks;  /* number of non-inuse chunks */
  int smblks;   /* unused -- always zero */
  int hblks;    /* number of mmapped regions */
  int hblkhd;   /* total space in mmapped regions */
  int usmblks;  /* unused -- always zero */
  int fsmblks;  /* unused -- always zero */
  int uordblks; /* total allocated space */
  int fordblks; /* total non-inuse space */
  int keepcost; /* top-most, releasable (via malloc_trim) space */
};

extern struct mallinfo mallinfo __P((void));

extern int mallopt __P((int __param, int __val));
/* Valid param_number values. */
#ifndef M_TRIM_THRESHOLD
#define M_TRIM_THRESHOLD	-1
#endif
#ifndef M_TOP_PAD
#define M_TOP_PAD		-2
#endif
#ifndef M_MMAP_THRESHOLD
#define M_MMAP_THRESHOLD	-3
#endif
#ifndef M_MMAP_MAX
#define M_MMAP_MAX		-4
#endif
	 
/* Record the state of all malloc variables in an opaque data structure. */
extern void * malloc_get_state __P ((void));

/* Restore the state of all malloc variables from data obtained with
   malloc_get_state(). */
extern int malloc_set_state __P ((void * __ptr));

__END_DECLS


#endif /* malloc.h  */
