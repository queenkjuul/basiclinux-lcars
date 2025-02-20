/*
 * Copyright 1988 - 1994, John F. Haugh II
 * All rights reserved.
 *
 * This software is derived from the Shadow Password Suite, version 3.3.2.
 * No portion of this comment block or copyright statement may be altered
 * without the written permission of the copyright holder.
 *
 *    This library is free software; you can redistribute it and/or modify
 *    it under the terms of the GNU Library General Public License as
 *    published by the Free Software Foundation; either version 2 of the
 *    License, or (at your option) any later version.
 *
 *    This library is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU Library General Public License for more details.
 *
 *    You should have received a copy of the GNU Library General Public
 *    License along with this program; if not, write to the Free Software
 *    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 */

#ifndef _SHADOW_H
#define _SHADOW_H	1

#include <features.h>

__BEGIN_DECLS

#include <gnu/types.h>
#include <stdio.h>
#include <time.h>
#include <pwd.h>
#include <grp.h>

/*
 * This information is not derived from AT&T licensed sources.  Posted
 * to the USENET 11/88, and updated 11/90 with information from SVR4.
 *
 *     @(#)shadow.h    1.1     12:23:13        13 Feb 1994     (GNU Shadow Library Suite)
 */


/*
 * Shadow password security file structure.
 */

struct spwd
{
  char *sp_namp;		/* login name */
  char *sp_pwdp;		/* encrypted password */
  time_t sp_lstchg;		/* date of last change */
  time_t sp_min;		/* minimum number of days between changes */
  time_t sp_max;		/* maximum number of days between changes */
  time_t sp_warn;		/* number of days of warning before password
				   expires */
  time_t sp_inact;		/* number of days after password expires
				   until the account becomes unusable. */
  time_t sp_expire;		/* days since 1/1/70 until account expires */
  unsigned long sp_flag;	/* reserved for future use */
};

/*
 * Shadow password security file functions.
 */

extern void setspent __P ((void));
extern void endspent __P ((void));
extern struct spwd *sgetspent __P ((__const char *__string));
extern struct spwd *fgetspent __P ((FILE *__fp));
extern struct spwd *getspent __P ((void));
extern struct spwd *getspnam __P ((__const char *__name));
extern int putspent __P ((__const struct spwd *__sp, FILE *__fp));

#define SHADOW "/etc/shadow"

/*
 *     @(#)gshadow.h   1.1     12:22:59        13 Feb 1994     (GNU Shadow Library Suite)
 *
 * Shadow group security file structure
 */

struct	sgrp
{
  char *sg_name;		/* group name */
  char *sg_passwd;		/* group password */
  char **sg_adm;		/* group administator list */
  char **sg_mem;		/* group membership list */
};

/*
 * Shadow group security file functions.
 */

extern void setsgent __P ((void));
extern void endsgent __P ((void));
extern struct sgrp *sgetsgent __P ((__const char *__string));
extern struct sgrp *fgetsgent __P ((FILE *__fp));
extern struct sgrp *getsgent __P ((void));
extern struct sgrp *getsgnam __P ((__const char *__str));
extern int putsgent __P ((__const struct sgrp *_grp, FILE *__fp));

#define GSHADOW "/etc/gshadow"

__END_DECLS

#endif /* shadow.h */
