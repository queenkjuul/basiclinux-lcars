/* Message catalogs for internationalization.
   Copyright (C) 1995, 1996, 1997 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
   USA.  */

#ifndef _LIBINTL_H
#define _LIBINTL_H	1

#include <locale.h>

/* We define an additional symbol to signal that we use the GNU
   implementation of gettext.  */
#define __USE_GNU_GETTEXT 1

#ifndef PARAMS
# if __STDC__ || defined __cplusplus
#  define PARAMS(args) args
# else
#  define PARAMS(args) ()
# endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* Look up MSGID in the current default message catalog for the current
   LC_MESSAGES locale.  If not found, returns MSGID itself (the default
   text).  */
extern char *gettext PARAMS ((const char *__msgid));

/* Look up MSGID in the DOMAINNAME message catalog for the current
   LC_MESSAGES locale.  */
extern char *dgettext PARAMS ((const char *__domainname, const char *__msgid));

/* Look up MSGID in the DOMAINNAME message catalog for the current CATEGORY
   locale.  */
extern char *dcgettext PARAMS ((const char *__domainname, const char *__msgid,
				int __category));


/* Set the current default message catalog to DOMAINNAME.
   If DOMAINNAME is null, return the current default.
   If DOMAINNAME is "", reset to the default of "messages".  */
extern char *textdomain PARAMS ((const char *__domainname));

/* Specify that the DOMAINNAME message catalog will be found
   in DIRNAME rather than in the system locale data base.  */
extern char *bindtextdomain PARAMS ((const char *__domainname,
				     const char *__dirname));


/* Optimized version of the functions above.  */
#if defined __OPTIMIZED
/* These must be a macro.  Inlined functions are useless because the
   `__builtin_constant_p' predicate in dcgettext would always return
   false.  */

# define gettext(msgid) dgettext ((char *) 0, msgid)

# define dgettext(domainname, msgid)					      \
  dcgettext (domainname, msgid, LC_MESSAGES)

# if __GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 7)
/* This global variable is defined in loadmsgcat.c.  We need a sign,
   whether a new catalog was loaded, which can be associated with all
   translations.  */
extern int _nl_msg_cat_cntr;

#  define dcgettext(domainname, msgid, category)			      \
  (__extension__							      \
   ({									      \
     char *__result;							      \
     if (__builtin_constant_p (msgid))					      \
       {								      \
	 static char *__translation__;					      \
	 static int __catalog_counter__;				      \
	 if (! __translation__ || __catalog_counter__ != _nl_msg_cat_cntr)    \
	   {								      \
	     __translation__ =						      \
	       (dcgettext) ((domainname), (msgid), (category));		      \
	     __catalog_counter__ = _nl_msg_cat_cntr;			      \
	   }								      \
	 __result = __translation__;					      \
       }								      \
     else								      \
       __result = (dcgettext) ((domainname), (msgid), (category));	      \
     __result;								      \
    }))
# endif
#endif /* Optimizing. */


#ifdef __cplusplus
}
#endif

#endif /* libintl.h */
