/* Copyright (C) 1991, 1992, 1993, 1994 Free Software Foundation, Inc.
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
 *	POSIX Standard: 7.1-2 General Terminal Interface	<termios.h>
 */

#ifndef _TERMIOS_H
#define _TERMIOS_H

#include <features.h>
#include <sys/types.h>
#include <linux/termios.h>

__BEGIN_DECLS

#ifdef __SVR4_I386_ABI_L1__
#define CTRL(ch)	((ch)&0x1F)
#define	IBSHIFT		16

#define CNUL	0
#define CDEL	0177
#define CESC	'\\'
#define CINTR	0177
#define CQUIT	034
#define CERASE	'#'
#define CKILL	'@'
#define CEOT	04
#define CEOL	0
#define CEOL2	0
#define CEOF	4
#define CSTART	021
#define CSTOP	023
#define CSWTCH	032
#define NSWTCH	0
#define CSUSP	CTRL('Z')
#define CDSUSP	CTRL('Y')
#define CRPRNT	CTRL('R')
#define CFLUSH	CTRL('O')
#define CWERASE	CTRL('W')
#define CLNEXT	CTRL('V')

#endif /* __SVR4_I386_ABI_L1__ */


/* Return the input baud rate stored in *TERMIOS_P.  */
extern speed_t cfgetispeed __P ((struct termios *__termios_p));

/* Return the output baud rate stored in *TERMIOS_P.  */
extern speed_t cfgetospeed __P ((struct termios *__termios_p));


/* Set *T to indicate raw mode.  */
extern void cfmakeraw  __P ((struct termios *__t));

/* Set the input baud rate stored in *TERMIOS_P to SPEED.  */
extern int cfsetispeed __P ((struct termios *__termios_p,
		speed_t __speed));

/* Set the output baud rate stored in *TERMIOS_P to SPEED.  */
extern int cfsetospeed __P ((struct termios *__termios_p,
		speed_t __speed));


/* Wait for pending output to be written on FILDES.  */
extern int tcdrain __P ((int __fildes));

/* Suspend or restart transmission on FILDES.
   Values for ACTION (TC[IO]{OFF,ON}) are in <linux/termios.h>.  */
extern int tcflow __P ((int __fildes, int __action));

/* Flush pending data on FILDES.
   Values for QUEUE_SELECTOR (TC{I,O,IO}FLUSH) are in <linux/termios.h>.  */
extern int tcflush __P ((int __fildes, int __queue_selector));

/* Return the foreground process group ID of FILDES.  */
extern pid_t tcgetpgrp __P ((int __fildes));

/* Put the state of FD into *TERMIOS_P.  */
extern int tcgetattr __P ((int __fildes, struct termios *__termios_p));
extern int __tcgetattr __P ((int __fildes, struct termios *__termios_p));

/* Send zero bits on FILDES.  */
extern int tcsendbreak __P ((int __fildes, int __duration));

/* Set the state of FILDES to *TERMIOS_P.
   Values for OPTIONAL_ACTIONS (TCSA*) are in <linux/termios.h>.  */
extern int tcsetattr __P ((int __fildes, int __optional_actions,
	struct termios *__termios_p));

/* Set the foreground process group ID of FILDES set PGRP_ID.  */
extern int tcsetpgrp __P ((int __fildes, pid_t __pgrp_id));

__END_DECLS

#endif
