/* Copyright (C) 1993  Olaf Flebbe
This file is part of the Linux C Library.

The Linux C Library is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public License as
published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version.

The Linux C Library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.  */

#ifndef _I386_FPU_CONTROL_H
#define _I386_FPU_CONTROL_H

/* Here is the dirty part. Settup up your 387 through the control word
 * (cw) register. 
 *
 *     15-13    12  11-10  9-8     7-6     5    4    3    2    1    0
 * | reserved | IC | RC  | PC | reserved | PM | UM | OM | ZM | DM | IM
 *
 * IM: Invalid operation mask
 * DM: Denormalized operand mask
 * ZM: Zero-divide mask
 * OM: Overflow mask
 * UM: Underflow mask
 * PM: Precision (inexact result) mask
 * 
 * Mask bit is 1 means no interrupt.
 *
 * PC: Precision control
 * 11 - round to extended precision
 * 10 - round to double precision
 * 00 - round to single precision
 *
 * RC: Rounding control
 * 00 - rounding to nearest
 * 01 - rounding down (toward - infinity)
 * 10 - rounding up (toward + infinity)
 * 11 - rounding toward zero
 *
 * IC: Infinity control
 * That is for 8087 and 80287 only.
 *
 * The hardware default is 0x037f. I choose 0x1372.
 */

#include <features.h>

/* masking of interrupts */
#define _FPU_MASK_IM  0x01  
#define _FPU_MASK_DM  0x02
#define _FPU_MASK_ZM  0x04
#define _FPU_MASK_OM  0x08
#define _FPU_MASK_UM  0x10
#define _FPU_MASK_PM  0x20

/* precision control */
#define _FPU_EXTENDED 0x300   /* RECOMMENDED */
#define _FPU_DOUBLE   0x200
#define _FPU_SINGLE   0x0     /* DO NOT USE */

/* rounding control */
#define _FPU_RC_NEAREST 0x0    /* RECOMMENDED */
#define _FPU_RC_DOWN    0x400
#define _FPU_RC_UP      0x800
#define _FPU_RC_ZERO    0xC00

#define _FPU_RESERVED 0xF0C0  /* Reserved bits in cw */


/* Now two recommended cw */

/* Linux default:
     - extended precision
     - rounding to nearest
     - exceptions on overflow, zero divide and NaN */
#if 0
#define _FPU_DEFAULT  0x1372 
#else
/* It seems SVR4/x86 uses the same thing. */
#define _FPU_DEFAULT  0x137f 
#endif

/* IEEE:  same as above, but exceptions */
#define _FPU_IEEE     0x137f

/* private namespace. It should only be used by crt0.o. */
extern unsigned short __fpu_control;

__BEGIN_DECLS

/* called by crt0.o. It can be used to manipulate 387 control word. */
extern void __setfpucw __P ((unsigned short));

__END_DECLS

#endif	/* _I386_FPU_CONTROL */
