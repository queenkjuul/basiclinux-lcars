#ifndef _FPU_CONTROL_H
#define _FPU_CONTROL_H

#if defined(__i386__)
# include <i386/fpu_control.h>
#elif defined(__mc68000__)
# include <m68k/fpu_control.h>
#else
# error architecture not supported by Linux C library
#endif 

#endif /* _FPU_CONTROL_H */
