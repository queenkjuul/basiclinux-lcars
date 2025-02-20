/* `sysconf', `pathconf', and `confstr' NAME values.  Generic version.
Copyright (C) 1993 Free Software Foundation, Inc.
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
not, write to the Free Software Foundation, Inc., 675 Mass Ave,
Cambridge, MA 02139, USA.  */

#ifndef _CONFNAME_H
#define _CONFNAME_H

/* Values for the NAME argument to `pathconf' and `fpathconf'.  */
enum
  {
    _PC_LINK_MAX
#ifdef __SVR4_I386_ABI_L1__
	= 1
#endif
    ,
    _PC_MAX_CANON,
    _PC_MAX_INPUT,
    _PC_NAME_MAX,
    _PC_PATH_MAX,
    _PC_PIPE_BUF,
#ifndef __SVR4_I386_ABI_L1__
    _PC_CHOWN_RESTRICTED,
#endif
    _PC_NO_TRUNC,
    _PC_VDISABLE,
#ifdef __SVR4_I386_ABI_L1__
    ,
    _PC_CHOWN_RESTRICTED,
#endif
    /* the following ones are new in POSIX.1b-1993 */
    _PC_ASYNC_IO,
    _PC_PRIO_IO,
    _PC_SYNC_IO
  };

/* Values for the argument to `sysconf'.  */
enum
  {
    _SC_ARG_MAX
#ifdef __SVR4_I386_ABI_L1__
    = 1
#endif /*__SVR4_I386_ABI_L1__*/
    ,
    _SC_CHILD_MAX,
    _SC_CLK_TCK,
    _SC_NGROUPS_MAX,
    _SC_OPEN_MAX,

#ifndef __SVR4_I386_ABI_L1__
    _SC_STREAM_MAX,
    _SC_TZNAME_MAX,
#endif /*!__SVR4_I386_ABI_L1__*/
    _SC_JOB_CONTROL,
    _SC_SAVED_IDS,
    _SC_VERSION,
#ifdef __SVR4_I386_ABI_L1__
    _SC_PASS_MAX,
    _SC_LOGNAME_MAX,
#endif /*__SVR4_I386_ABI_L1__*/
    _SC_PAGESIZE,
#ifdef __SVR4_I386_ABI_L1__
    _SC_XOPEN_VERSION,
    _SC_STREAM_MAX,
    _SC_TZNAME_MAX,
#endif /*__SVR4_I386_ABI_L1__*/
    /* Values for the argument to `sysconf'
       corresponding to _POSIX2_* symbols.  */
    _SC_BC_BASE_MAX,
    _SC_BC_DIM_MAX,
    _SC_BC_SCALE_MAX,
    _SC_BC_STRING_MAX,
    _SC_COLL_WEIGHTS_MAX,
    _SC_EQUIV_CLASS_MAX,
    _SC_EXPR_NEST_MAX,
    _SC_LINE_MAX,
    _SC_RE_DUP_MAX,

    _SC_2_VERSION,
    _SC_2_C_BIND,
    _SC_2_C_DEV,
    _SC_2_FORT_DEV,
    _SC_2_FORT_RUN,
    _SC_2_SW_DEV,
    _SC_2_LOCALEDEF,

    /* the following ones are new in POSIX.1b-1993 */
    _SC_AIO_LISTIO_MAX,
    _SC_AIO_MAX,
    _SC_AIO_PRIO_DELTA_MAX,
    _SC_DELAYTIMER_MAX,
    _SC_MQ_OPEN_MAX,
    _SC_MQ_PRIO_MAX,
    _SC_RTSIG_MAX,
    _SC_SEM_NSEMS_MAX,
    _SC_SEM_VALUE_MAX,
    _SC_SIGQUEUE_MAX,
    _SC_TIMER_MAX,
    _SC_ASYNCHRONOUS_IO,
    _SC_FSYNC,
    _SC_MAPPED_FILES,
    _SC_MEMLOCK,
    _SC_MEMLOCK_RANGE,
    _SC_MEMORY_PROTECTION,
    _SC_MESSAGE_PASSING,
    _SC_PRIORITIZED_IO,
    _SC_PRIORITY_SCHEDULING,
    _SC_REALTIME_SIGNALS,
    _SC_SEMAPHORES,
    _SC_SHARED_MEMORY_OBJECTS,
    _SC_SYNCHRONIZED_IO,
    _SC_TIMERS
  };

#ifdef __USE_POSIX2
/* Values for the NAME argument to `confstr'.  */
enum
  {
    _CS_PATH			/* The default search path.  */
  };
#endif

/* HP-UX wants it. */
#ifndef _SC_PAGE_SIZE
#define _SC_PAGE_SIZE	_SC_PAGESIZE
#endif

#endif	/* confname.h */
