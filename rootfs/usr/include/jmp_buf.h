#ifndef _JMP_BUF_H
#define _JMP_BUF_H

#if defined(__i386__)
# include <i386/jmp_buf.h>
#elif defined(__mc68000__)
# include <m68k/jmp_buf.h>
#else
# error architecture not supported by Linux C library
#endif 

#endif /* _JMP_BUF_H */
