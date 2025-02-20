/* Copyright (C) 1991, 1992, 1993 Free Software Foundation, Inc.
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
License along with the GNU C Library; see the file COPYING.LIB.  If
not, write to the, 1992 Free Software Foundation, Inc., 675 Mass Ave,
Cambridge, MA 02139, USA.  */

/*
 *	ANSI Standard: 4.6 NON-LOCAL JUMPS <setjmp.h>
 */

#ifndef	_SETJMP_H

#define	_SETJMP_H	1
#include <features.h>

__BEGIN_DECLS

/* Get the machine-dependent definition of `__jmp_buf'.  */
#include <jmp_buf.h>


#ifdef	__USE_POSIX
#define	__need_sigset_t
#include <signal.h>

/* Calling environment, plus possibly a saved signal mask.  */
typedef struct __sigjmp_buf_base
  {
    __jmp_buf __jmpbuf;		/* Calling environment.  */
    int __mask_was_saved;	/* Saved the signal mask?  */
    sigset_t __saved_mask;	/* Saved signal mask.  */
#ifdef __SVR4_I386_ABI_L1__
    unsigned long pad1[116];
#endif /* __SVR4_I386_ABI_L1__ */
  } sigjmp_buf[1];

/* Store the calling environment in ENV, also saving the
   signal mask if SAVEMASK is nonzero.  Return 0.  */
extern void __sigjmp_save __P ((sigjmp_buf __env, int __savemask));
#ifdef __GNUC__
#define	sigsetjmp(env, savemask) \
  __extension__								      \
  ({ __typeof ((*((sigjmp_buf *) 0))[0]) *__e = (env);			      \
     __sigjmp_save (__e, (savemask));					      \
     __setjmp (__e[0].__jmpbuf); })
#else
/* Not strictly POSIX-compliant, because it evaluates ENV more than once.  */
#define	sigsetjmp(env, savemask) \
  (__sigjmp_save ((env), (savemask)), __setjmp ((env)[0].__jmpbuf))
#endif


/* Jump to the environment saved in ENV, making the
   sigsetjmp call there return VAL, or 1 if VAL is 0.
   Restore the signal mask if that sigsetjmp call saved it.  */
extern __NORETURN void siglongjmp __P ((sigjmp_buf __env,
					int __val)) __NORETURN2;
#endif /* Use POSIX.  */


#ifdef	__FAVOR_BSD

/* BSD defines `setjmp' and `longjmp' to save and restore the set of
   blocked signals.  For this, `jmp_buf' must be what POSIX calls
   `sigjmp_buf', which includes that information.  */
typedef sigjmp_buf jmp_buf;

#else /* Don't favor BSD.  */

/* A `jmp_buf' really is a `jmp_buf'.  Oh boy.  */
typedef __jmp_buf jmp_buf;

#endif /* Favor BSD.  */


/* Jump to the environment saved in ENV, making the
   setjmp call there return VAL, or 1 if VAL is 0.  */
extern __NORETURN void __longjmp __P ((__jmp_buf __env,
				       int __val)) __NORETURN2;
extern __NORETURN void longjmp __P ((jmp_buf __env,
				     int __val)) __NORETURN2;

/* Set ENV to the current position and return 0.  */
extern int __setjmp __P ((__jmp_buf __env));
/* The ANSI C standard says `setjmp' is a macro.  */
#define	setjmp(env)	__setjmp (env)


#ifdef	__USE_BSD
extern void __NORETURN _longjmp __P ((jmp_buf __env,
				      int __val)) __NORETURN2;
#endif /* Use BSD.  */

#ifdef	__FAVOR_BSD

/* We are in the mode in which `setjmp' and `longjmp' save and restore
   the signal mask, and `jmp_buf' is `sigjmp_buf'.  */

#undef	setjmp
#undef	longjmp

#define	setjmp(env)		sigsetjmp ((env), 1)

#define	longjmp(env, val)	siglongjmp ((env), (val))

#define	_setjmp(env)		sigsetjmp ((env), 0)

#else	/* Don't favor BSD.  */

/* `setjmp' and `_setjmp' are the same.  */
#define	_setjmp(env)		setjmp (env)

/* `longjmp' and `_longjmp' are the same.  */
#define	_longjmp(env, val)	longjmp ((env), (val))

#endif /* Favor BSD.  */

#ifdef __SVR4_I386_ABI_L1__
#define _SIGJBLEN	(sizeof(sigjmp_buf)/sizeof(int))
#define _JBLEN		(sizeof(jmp_buf)/sizeof(int))
#endif

__END_DECLS

#endif /* setjmp.h  */
