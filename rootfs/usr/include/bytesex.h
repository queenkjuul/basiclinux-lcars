#ifndef _BYTESEX_H
#define _BYTESEX_H

#undef __BYTE_ORDER

#if defined(__i386__) || defined(__alpha__) \
	|| (defined(__mips__) && (defined(MIPSEL) || defined (__MIPSEL__)))
# define __BYTE_ORDER	1234
#elif defined(__mc68000__) || defined (__sparc__) || defined (__PPC__) \
	|| (defined(__mips__) && (defined(MIPSEB) || defined (__MIPSEB__)))
# define __BYTE_ORDER	4321
#else
# error architecture not supported by the Linux C library
#endif

#endif /* _BYTESEX_H */
