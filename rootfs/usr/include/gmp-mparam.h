#ifndef _GMP_MPARAM_H
#define _GMP_MPARAM_H

#if defined(__i386__)
# include <i386/gmp-mparam.h>
#elif defined(__mc68000__)
# include <m68k/gmp-mparam.h>
#else
# error architecture not supported by Linux C library
#endif 

#endif /* _GMP_MPARAM_H */
