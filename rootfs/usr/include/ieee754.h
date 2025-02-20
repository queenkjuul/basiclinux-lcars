/* Copyright (C) 1992 Free Software Foundation, Inc.
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

#ifndef _IEEE754_H
#define _IEEE754_H

#include <endian.h>

union ieee754_double
  {
    double d;
    
    /* This is the IEEE 754 double-precision format.  */
    struct
      {
#if	__BYTE_ORDER == __BIG_ENDIAN
	unsigned int negative:1;
	unsigned int exponent:11;
	/* Together these comprise the mantissa.  */
	unsigned int mantissa0:20;
	unsigned int mantissa1:32;
#endif
#if	__BYTE_ORDER == __LITTLE_ENDIAN
	/* Together these comprise the mantissa.  */
	unsigned int mantissa1:32;
	unsigned int mantissa0:20;
	unsigned int exponent:11;
	unsigned int negative:1;
#endif
      } ieee;
    struct
      {
#if	__BYTE_ORDER == __BIG_ENDIAN
	unsigned int negative:1;
	unsigned int exponent:11;
	unsigned int quiet_nan:1;
	/* Together these conprise the mantissa.  */
	unsigned int mantissa0:19;
	unsigned int mantissa1:32;
#else
	/* Together these conprise the mantissa.  */
	unsigned int mantissa1:32;
	unsigned int mantissa0:19;
	unsigned int quiet_nan:1;
	unsigned int exponent:11;
	unsigned int negative:1;
#endif
      } ieee_nan;
  };

#define _IEEE754_DOUBLE_BIAS            0x3ff   /* added to exp of ieee754_double */

#if defined(__i386__)
# include <i386/ieeefp.h>
#elif defined(__mc68000__)
# include <m68k/ieeefp.h>
#endif

#endif	/* _IEEE754_H */
