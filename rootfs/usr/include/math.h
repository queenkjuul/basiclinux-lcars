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
 *      ANSI Standard: 4.5 MATHEMATICS  <math.h>
 */

#ifndef	_MATH_H
#define	_MATH_H

#include <features.h>

__BEGIN_DECLS

/* Trigonometric functions.  */

#if !defined(__mc68000__) || defined (__NO_MATH_INLINES)
/* Arc cosine of X.  */
extern __CONSTVALUE double acos __P ((double __x));
/* Arc sine of X.  */
extern __CONSTVALUE double asin __P ((double __x));
/* Arc tangent of X.  */
extern __CONSTVALUE double atan __P ((double __x)) __CONSTVALUE2;
#endif /* m68k inlines */
/* Arc tangent of Y/X.  */
extern __CONSTVALUE double atan2 __P ((double __y, double __x)) __CONSTVALUE2;

#if !defined(__mc68000__) || defined (__NO_MATH_INLINES)
/* Cosine of X.  */
extern __CONSTVALUE double cos __P ((double __x)) __CONSTVALUE2;
/* Sine of X.  */
extern __CONSTVALUE double sin __P ((double __x)) __CONSTVALUE2;
/* Tangent of X.  */
extern __CONSTVALUE double tan __P ((double __x)) __CONSTVALUE2;


/* Hyperbolic functions.  */

/* Hyperbolic cosine of X.  */
extern __CONSTVALUE double cosh __P ((double __x)) __CONSTVALUE2;
/* Hyperbolic sine of X.  */
extern __CONSTVALUE double sinh __P ((double __x)) __CONSTVALUE2;
/* Hyperbolic tangent of X.  */
extern __CONSTVALUE double tanh __P ((double __x)) __CONSTVALUE2;
#endif /* m68k inlines */

/* Hyperbolic arc cosine of X.  */
extern __CONSTVALUE double acosh __P ((double __x));
/* Hyperbolic arc sine of X.  */
extern __CONSTVALUE double asinh __P ((double __x));
#if !defined(__mc68000__) || defined (__NO_MATH_INLINES)
/* Hyperbolic arc tangent of X.  */
extern __CONSTVALUE double atanh __P ((double __x));
#endif /* m68k inlines */

/* Exponential and logarithmic functions.  */

#if !defined(__mc68000__) || defined (__NO_MATH_INLINES)
/* Exponentional function of X.  */
extern __CONSTVALUE double exp __P ((double __x)) __CONSTVALUE2;

/* Break VALUE into a normalized fraction and an integral power of 2.  */
extern              double frexp __P ((double __x, int *__exp));

/* X times (two to the EXP power).  */
extern __CONSTVALUE double ldexp __P ((double __x, int __exp));

/* Natural logarithm of X.  */
extern __CONSTVALUE double log __P ((double __x));

/* Base-ten logarithm of X.  */
extern __CONSTVALUE double log10 __P ((double __x));

/* Return exp(X) - 1.  */
extern __CONSTVALUE double expm1 __P ((double __x)) __CONSTVALUE2;

/* Return log(1 + X).  */
extern __CONSTVALUE double log1p __P ((double __x));

/* Break VALUE into integral and fractional parts.  */
extern              double modf __P ((double __x, double *__iptr));
#endif /* m68k inlines */


/* Power functions.  */

#if !defined(__mc68000__) || defined (__NO_MATH_INLINES)
/* Return X to the Y power.  */
extern __CONSTVALUE double pow __P ((double __x, double __y));

/* Return the square root of X.  */
extern __CONSTVALUE double sqrt __P ((double __x));
#endif /* m68k inlines */

/* Return the cube root of X.  */
extern __CONSTVALUE double cbrt  __P ((double __x)) __CONSTVALUE2;


/* Nearest integer, absolute value, and remainder functions.  */

#if !defined(__mc68000__) || defined (__NO_MATH_INLINES)
/* Smallest integral value not less than X.  */
extern __CONSTVALUE double ceil __P ((double __x)) __CONSTVALUE2;

/* Absolute value of X.  */
extern __CONSTVALUE double fabs __P ((double __x)) __CONSTVALUE2;

/* Largest integer not greater than X.  */
extern __CONSTVALUE double floor __P ((double __x)) __CONSTVALUE2;

/* Floating-point modulo remainder of X/Y.  */
extern __CONSTVALUE double fmod __P ((double __x, double __y)) __CONSTVALUE2;


/* Return 0 if VALUE is finite or NaN, +1 if it
   is +Infinity, -1 if it is -Infinity.  */
extern __CONSTVALUE int __isinf __P ((double __value)) __CONSTVALUE2;

/* Return nonzero if VALUE is not a number.  */
extern __CONSTVALUE int __isnan __P ((double __value)) __CONSTVALUE2;
#endif /* m68k inlines */

/* Return nonzero if VALUE is finite and not NaN.  */
extern __CONSTVALUE int __finite __P ((double __value)) __CONSTVALUE2;
#ifdef	__OPTIMIZE__
#define	__finite(value)	(!__isinf (value) && !__isnan (value))
#endif

/* Deal with an infinite or NaN result.
   If ERROR is ERANGE, result is +Inf;
   if ERROR is - ERANGE, result is -Inf;
   otherwise result is NaN.
   This will set `errno' to either ERANGE or EDOM,
   and may return an infinity or NaN, or may do something else.  */
extern double __infnan __P ((int __error));
extern long double __infnanl __P((int __error));

/* Return X with its signed changed to Y's.  */
extern __CONSTVALUE double __copysign __P ((double __x,
					    double __y)) __CONSTVALUE2;

extern __CONSTVALUE __long_double_t __copysignl __P ((__long_double_t __x,
						      __long_double_t __y )) 
     __CONSTVALUE2;
 

#if !defined(__mc68000__) || defined (__NO_MATH_INLINES)
/* Return the integer nearest X in the direction of the
   prevailing rounding mode.  */
extern __CONSTVALUE double __rint __P ((double __x)) __CONSTVALUE2;
extern __CONSTVALUE double rint __P ((double __x)) __CONSTVALUE2;
#endif /* m68k inlines */

/* Return `sqrt(X*X + Y*Y)'.  */
extern __CONSTVALUE double hypot __P ((double __x, double __y)) __CONSTVALUE2;

#ifdef	__USE_MISC

extern __CONSTVALUE int isinf __P ((double __value)) __CONSTVALUE2;
extern __CONSTVALUE int isinfl __P ((__long_double_t __value)) __CONSTVALUE2;
extern __CONSTVALUE int isnan __P ((double __value)) __CONSTVALUE2;
extern __CONSTVALUE int isnanl __P ((__long_double_t __value)) __CONSTVALUE2;
extern __CONSTVALUE int finite __P ((double __value)) __CONSTVALUE2;
extern __CONSTVALUE double infnan __P ((int __error)) __CONSTVALUE2;
extern __CONSTVALUE __long_double_t infnanl __P ((int __error)) __CONSTVALUE2;
extern __CONSTVALUE double copysign __P ((double __x,
					  double __y)) __CONSTVALUE2;
extern __CONSTVALUE __long_double_t copysignl __P ((__long_double_t __x,
						    __long_double_t __y))
     __CONSTVALUE2;
extern __CONSTVALUE double drem __P ((double __x, double __y)) __CONSTVALUE2;

/*
#define FP_NAN       1
#define FP_INFINITE  2
#define FP_NORMAL    3
#define FP_SUBNORMAL 4
#define FP_ZERO      5

extern __CONSTVALUE int fpclassifyf( float _x) __CONSTVALUE2;
extern __CONSTVALUE int fpclassifyd( double _x)  __CONSTVALUE2;
extern __CONSTVALUE int fpclassifyl( __long_double_t _x) __CONSTVALUE2;
*/

#ifdef	__OPTIMIZE__
#define	isinf(value)	__isinf(value)
#define isinfl(value)	__isinfl(value)
#define	isnan(value)	__isnan(value)
#define	isnanl(value)	__isnanl(value)
#define	infnan(error)	__infnan(error)
#define	infnanl(error)	__infnanl(error)
#define	finite(value)	__finite(value)
#define	copysign(x, y)	__copysign((x), (y))
#define	copysignl(x, y)	__copysignl((x), (y))
#endif /* Optimizing.  */

#endif /* Use misc.  */


/* some other functions not in GNU libc */

/* Return 2 to the X power.  */
extern __CONSTVALUE double pow2 __P ((double __x)) __CONSTVALUE2;

/* Return 10 to the X power.  */
extern __CONSTVALUE double pow10 __P ((double __x)) __CONSTVALUE2;

/* Return the error function of X. */
extern __CONSTVALUE double erf  __P ((double __x)) __CONSTVALUE2;

/* Return the complementary error function of X.  */
extern __CONSTVALUE double erfc  __P ((double __x)) __CONSTVALUE2;

/* Return the Bessel function of X of the first kind of order 0.  */
extern __CONSTVALUE double j0  __P ((double __x)) __CONSTVALUE2;

/* Return the Bessel function of X of the first kind of order 1.  */
extern __CONSTVALUE double j1  __P ((double __x)) __CONSTVALUE2;

/* Return the Bessel function of X of the first kind of order N.  */
extern __CONSTVALUE double jn  __P ((int __n, double __x)) __CONSTVALUE2;

/* Return the log of the absolute value of the Gamma function of X.  */
extern __CONSTVALUE double lgamma  __P ((double __x));

/* Return the Bessel function of X of the second kind of order 0.  */
extern __CONSTVALUE double y0  __P ((double __x)) __CONSTVALUE2;

/* Return the Bessel function of X of the second kind of order 1.  */
extern __CONSTVALUE double y1  __P ((double __x)) __CONSTVALUE2;

/* Return the Bessel function of X of the second kind of order N.  */
extern __CONSTVALUE double yn  __P ((int __n, double __x)) __CONSTVALUE2;

#if !defined (__mc68000__) || defined (__NO_MATH_INLINES)
extern __CONSTVALUE __long_double_t acosl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t asinl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t atanl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t cosl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t sinl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t tanl __P ((__long_double_t __x));
#endif /* m68k inlines */
extern __CONSTVALUE __long_double_t acoshl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t asinhl __P ((__long_double_t __x));
#if !defined (__mc68000__) || defined (__NO_MATH_INLINES)
extern __CONSTVALUE __long_double_t atanhl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t coshl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t sinhl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t tanhl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t expl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t expm1l __P ((__long_double_t __x)) __CONSTVALUE2;
extern __long_double_t frexpl __P ((__long_double_t __value, int *__exp));
extern __CONSTVALUE __long_double_t ldexpl __P ((__long_double_t __x, int __exp));
extern __CONSTVALUE __long_double_t logl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t log10l __P ((__long_double_t __x));
extern __long_double_t modfl __P ((__long_double_t __value, __long_double_t * __ip));
extern __CONSTVALUE __long_double_t powl __P ((__long_double_t __x, __long_double_t __y));
extern __CONSTVALUE __long_double_t sqrtl __P ((__long_double_t __x));
#endif /* m68k inlines */
extern __CONSTVALUE __long_double_t atan2l __P ((__long_double_t __y, __long_double_t __x));
extern __CONSTVALUE __long_double_t hypotl __P ((__long_double_t __x, __long_double_t __y)) __CONSTVALUE2;

extern __CONSTVALUE __long_double_t erfl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t erfcl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t lgammal __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t j0l __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t y0l __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t j1l __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t y1l __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t jnl __P ((int __n, __long_double_t __x));
extern __CONSTVALUE __long_double_t ynl __P ((int __n, __long_double_t __x));
extern __CONSTVALUE __long_double_t cbrtl __P ((__long_double_t __x));
#if !defined (__mc68000__) || defined (__NO_MATH_INLINES)
extern __CONSTVALUE __long_double_t log1pl __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t log2l __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t pow2l __P ((__long_double_t __x));
extern __CONSTVALUE __long_double_t pow10l __P ((__long_double_t __x));

/* Smallest integral value not less than X.  */
extern __CONSTVALUE __long_double_t ceill __P ((__long_double_t __x)) __CONSTVALUE2;

/* Absolute value of X.  */
extern __CONSTVALUE __long_double_t fabsl __P ((__long_double_t __x)) __CONSTVALUE2;

/* Largest integer not greater than X.  */
extern __CONSTVALUE __long_double_t floorl __P ((__long_double_t __x)) __CONSTVALUE2;

/* Floating-point modulo remainder of X/Y.  */
extern __CONSTVALUE __long_double_t fmodl __P ((__long_double_t __x,
						__long_double_t __y)) __CONSTVALUE2;


/* Return 0 if VALUE is finite or NaN, +1 if it
   is +Infinity, -1 if it is -Infinity.  */
extern __CONSTVALUE int __isinfl __P ((__long_double_t __value)) __CONSTVALUE2;

/* Return nonzero if VALUE is not a number.  */
extern __CONSTVALUE int __isnanl __P ((__long_double_t __value)) __CONSTVALUE2;
#endif /* m68k inlines */

__END_DECLS

extern int signgam;
extern int signgaml;

/* Get machine-dependent HUGE_VAL value (returned on overflow).  */
#include <huge_val.h>

/* Get machine-dependent NAN value (returned for some domain errors).  */
#ifdef   __USE_GNU
#include <nan.h>
#endif
 
#include <float.h>
#include <values.h>

#ifndef HUGE
#define HUGE		DBL_MAX
#endif

#ifndef HUGE_VAL
#define HUGE_VAL	DBL_MAX
#endif

#ifndef M_E
#define M_E         2.7182818284590452354	/* e */
#endif
#ifndef M_LOG2E
#define M_LOG2E     1.4426950408889634074	/* log 2e */
#endif
#ifndef M_LOG10E
#define M_LOG10E    0.43429448190325182765	/* log 10e */
#endif
#ifndef M_LN2
#define M_LN2       0.69314718055994530942	/* log e2 */
#endif
#ifndef M_LN10
#define M_LN10      2.30258509299404568402	/* log e10 */
#endif
#ifndef M_PI
#define M_PI        3.14159265358979323846	/* pi */
#endif
#ifndef M_PI_2
#define M_PI_2      1.57079632679489661923	/* pi/2 */
#endif
#ifndef M_1_PI
#define M_1_PI      0.31830988618379067154	/* 1/pi */
#endif
#ifndef M_PI_4
#define M_PI_4      0.78539816339744830962	/* pi/4 */
#endif
#ifndef M_2_PI
#define M_2_PI      0.63661977236758134308	/* 2/pi */
#endif
#ifndef M_2_SQRTPI
#define M_2_SQRTPI  1.12837916709551257390	/* 2/sqrt(pi) */
#endif
#ifndef M_SQRT2
#define M_SQRT2     1.41421356237309504880	/* sqrt(2) */
#endif
#ifndef M_SQRT1_2
#define M_SQRT1_2   0.70710678118654752440	/* 1/sqrt(2) */
#endif

#ifndef PI                      /* as in stroustrup */
#define PI  M_PI
#endif
#ifndef PI2
#define PI2  (M_PI + M_PI)
#endif

#if defined(__mc68000__)
# include <m68k/__math.h>
#endif


#ifndef __NO_MATH_INLINES
#  include <ieee754.h>
#  include <ieee854.h>

extern __inline __CONSTVALUE double __copysign __P ((double __x,
					    double __y)) 
{
  union ieee754_double *__ux = (union ieee754_double *) &__x;
  union ieee754_double *__uy = (union ieee754_double *) &__y;

  __ux->ieee.negative = __uy->ieee.negative;

  return __x;
}

extern __inline __CONSTVALUE __long_double_t __copysignl __P ((__long_double_t __x, __long_double_t __y )) 
{
  union ieee854_double *__ux = (union ieee854_double *) &__x;
  union ieee854_double *__uy = (union ieee854_double *) &__y;

  __ux->ieee.negative = __uy->ieee.negative;

  return __x;
}

#endif /* __NO_MATH_INLINES */
#endif /* _MATH_H */
