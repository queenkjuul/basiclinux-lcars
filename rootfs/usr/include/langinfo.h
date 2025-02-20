/* nl_langinfo -- Access to locale-dependent parameters.
Copyright (C) 1995, 1996 Free Software Foundation, Inc.
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

#ifndef _LANGINFO_H
#define	_LANGINFO_H 1

#include <locale.h>		/* Define the LC_* category names.  */

__BEGIN_DECLS

/* Construct an `nl_item' value for `nl_langinfo' from a locale category
   (LC_*) and an item index within the category.  Some code may depend on
   the item values within a category increasing monotonically with the
   indices.  */
#define _NL_ITEM(category, index)	(((category) << 16) | (index))

/* Extract the category and item index from a constructed `nl_item' value.  */
#define _NL_ITEM_CATEGORY(item)		((int) (item) >> 16)
#define _NL_ITEM_INDEX(item)		((int) (item) & 0xffff)


/* Enumeration of locale items that can be queried with `nl_langinfo'.  */
typedef enum
{
  /* LC_TIME category: date and time formatting.  */

#ifdef __SVR4_I386_ABI_L1__
  /* Long-named days of the week. */
  DAY_1 = 1,			/* 1 Sunday */
  DAY_2,			/* 2 Monday */
  DAY_3,			/* 3 Tuesday */
  DAY_4,			/* 4 Wednesday */
  DAY_5,			/* 5 Thursday */
  DAY_6,			/* 6 Friday */
  DAY_7,			/* 7 Saturday */

  /* Abbreviated days of the week. */
  ABDAY_1,			/* 8 Sun */
  ABDAY_2,			/* 9 Mon */
  ABDAY_3,			/* 10 Tue */
  ABDAY_4,			/* 11 Wed */
  ABDAY_5,			/* 12 Thu */
  ABDAY_6,			/* 13 Fri */
  ABDAY_7,			/* 14 Sat */

#else /*!__SVR4_I386_ABI_L1__*/

  /* Abbreviated days of the week. */
  ABDAY_1 = _NL_ITEM (LC_TIME, 0), /* Sun */
  ABDAY_2,
  ABDAY_3,
  ABDAY_4,
  ABDAY_5,
  ABDAY_6,
  ABDAY_7,

  /* Long-named days of the week. */
  DAY_1,			/* Sunday */
  DAY_2,			/* Monday */
  DAY_3,			/* Tuesday */
  DAY_4,			/* Wednesday */
  DAY_5,			/* Thursday */
  DAY_6,			/* Friday */
  DAY_7,			/* Saturday */

#endif /*!__SVR4_I386_ABI_L1__*/


#ifdef __SVR4_I386_ABI_L1__
  /* Abbreviated month names.  */
  MON_1,			/* 15 = Jan */
  MON_2,			/* 16 = Feb */
  MON_3,			/* 17 = Mar */
  MON_4,			/* 18 = Apr */
  MON_5,			/* 19 = May */
  MON_6,			/* 20 = Jun */
  MON_7,			/* 21 = Jul */
  MON_8,			/* 22 = Aug */
  MON_9,			/* 23 = Sep */
  MON_10,			/* 24 = Oct */
  MON_11,			/* 25 = Nov */
  MON_12,			/* 26 = Dec */

  /* Long month names.  */
  ABMON_1,			/* 27 = January */
  ABMON_2,			/* 28 = February */
  ABMON_3,			/* 29 = March */
  ABMON_4,			/* 30 = April */
  ABMON_5,			/* 31 = May */
  ABMON_6,			/* 32 = June */
  ABMON_7,			/* 33 = July */
  ABMON_8,			/* 34 = August */
  ABMON_9,			/* 35 = September */
  ABMON_10,			/* 36 = October */
  ABMON_11,			/* 37 = November */
  ABMON_12,			/* 38 = December */

  RADIXCHAR,			/* 39 */
  THOUSEP,			/* 40 */
  YESSTR,			/* 41 = Output string for ``yes''.  */
  NOEXPR,			/* 42 = Regex matching ``no'' input.  */
  CRNCYSTR,			/* 43 */

  D_T_FMT,			/* 44 = Date and time format for strftime.  */
  D_FMT,			/* 45 = Date format for strftime.  */
  T_FMT,			/* 46 = Time format for strftime.  */

  AM_STR,			/* 47= Ante meridian string.  */
  PM_STR,			/* 48 = Post meridian string.  */

#else /*!__SVR4_I386_ABI_L1__*/
  /* Abbreviated month names.  */
  ABMON_1,			/* Jan */
  ABMON_2,
  ABMON_3,
  ABMON_4,
  ABMON_5,
  ABMON_6,
  ABMON_7,
  ABMON_8,
  ABMON_9,
  ABMON_10,
  ABMON_11,
  ABMON_12,

  /* Long month names.  */
  MON_1,			/* January */
  MON_2,
  MON_3,
  MON_4,
  MON_5,
  MON_6,
  MON_7,
  MON_8,
  MON_9,
  MON_10,
  MON_11,
  MON_12,

  AM_STR,			/* Ante meridian string.  */
  PM_STR,			/* Post meridian string.  */

  D_T_FMT,			/* Date and time format for strftime.  */
  D_FMT,			/* Date format for strftime.  */
  T_FMT,			/* Time format for strftime.  */
#endif /*!__SVR4_I386_ABI_L1__*/

  T_FMT_AMPM,			/* 12-hour time format for strftime.  */

  ERA,				/* Alternate era.  */
  ERA_YEAR,			/* Year in alternate era format.  */
  ERA_D_FMT,			/* Date in alternate era format.  */
  ALT_DIGITS,			/* Alternate symbols for digits.  */
  ERA_D_T_FMT,			/* Date and time in alternate era format.  */
  ERA_T_FMT,			/* Time in alternate era format.  */

  _NL_NUM_LC_TIME,		/* Number of indices in LC_TIME category.  */

  /* LC_COLLATE category: text sorting.
     This information is accessed by the strcoll and strxfrm functions.
     These `nl_langinfo' names are used only internally.  */
  _NL_COLLATE_NRULES = _NL_ITEM (LC_COLLATE, 0),
  _NL_COLLATE_RULES,
  _NL_COLLATE_HASH_SIZE,
  _NL_COLLATE_HASH_LAYERS,
  _NL_COLLATE_TABLE_EB,
  _NL_COLLATE_TABLE_EL,
  _NL_COLLATE_UNDEFINED,
  _NL_COLLATE_EXTRA_EB,
  _NL_COLLATE_EXTRA_EL,
  _NL_NUM_LC_COLLATE,

  /* LC_CTYPE category: character classification.
     This information is accessed by the functions in <ctype.h>.
     These `nl_langinfo' names are used only internally.  */
  _NL_CTYPE_CLASS = _NL_ITEM (LC_CTYPE, 0),
  _NL_CTYPE_TOUPPER_EB,
  _NL_CTYPE_TOLOWER_EB,
  _NL_CTYPE_TOUPPER_EL,
  _NL_CTYPE_TOLOWER_EL,
  _NL_CTYPE_CLASS32,
  _NL_CTYPE_NAMES_EB,
  _NL_CTYPE_NAMES_EL,
  _NL_CTYPE_HASH_SIZE,
  _NL_CTYPE_HASH_LAYERS,
  _NL_CTYPE_CLASS_NAMES,
  _NL_CTYPE_MAP_NAMES,
  _NL_CTYPE_WIDTH,
  _NL_NUM_LC_CTYPE,

  /* LC_MONETARY category: formatting of monetary quantities.
     These items each correspond to a member of `struct lconv',
     defined in <locale.h>.  */
  INT_CURR_SYMBOL = _NL_ITEM (LC_MONETARY, 0),
  CURRENCY_SYMBOL,
  MON_DECIMAL_POINT,
  MON_THOUSANDS_SEP,
  MON_GROUPING,
  POSITIVE_SIGN,
  NEGATIVE_SIGN,
  INT_FRAC_DIGITS,
  FRAC_DIGITS,
  P_CS_PRECEDES,
  P_SEP_BY_SPACE,
  N_CS_PRECEDES,
  N_SEP_BY_SPACE,
  P_SIGN_POSN,
  N_SIGN_POSN,
  _NL_NUM_LC_MONETARY,

  /* LC_NUMERIC category: formatting of numbers.
     These also correspond to members of `struct lconv'; see <locale.h>.  */
  DECIMAL_POINT = _NL_ITEM (LC_NUMERIC, 0),
  THOUSANDS_SEP,
  GROUPING,
  _NL_NUM_LC_NUMERIC,

  YESEXPR = _NL_ITEM (LC_MESSAGES, 0), /* Regex matching ``yes'' input.  */
#ifndef __SVR4_I386_ABI_L1__
  NOEXPR,			/* Regex matching ``no'' input.  */
  YESSTR,			/* Output string for ``yes''.  */
#endif
  NOSTR,			/* Output string for ``no''.  */
  _NL_NUM_LC_MESSAGES,

  /* This marks the highest value used.  */
  _NL_NUM
} nl_item;


/* XXX The SVR4 ABI defines nl_item as type int, declared in <nl_types.h>,
  but the Linux C library declares it as an enum in <langinfo.h>. */

/* Return the current locale's value for ITEM.
   If ITEM is invalid, an empty string is returned.

   The string returned will not change until `setlocale' is called;
   it is usually in read-only memory and cannot be modified.  */

extern char *nl_langinfo __P ((nl_item item));


__END_DECLS

#endif	/* langinfo.h */
