/*
 * Copyright (c) 1990,1991 Regents of The University of Michigan.
 * All Rights Reserved. See COPYRIGHT.
 */

#  ifndef _ATALK_ENDIAN_H_
#define _ATALK_ENDIAN_H_

#include <sys/types.h>
#include <netinet/in.h>
#ifdef s_net
#undef s_net  /* get rid of silly sunos #define */
#endif

#ifdef _IBMR2
#include <sys/machine.h>
#endif _IBMR2

#ifdef sun
#ifdef __svr4__
#ifdef _ISOC9X_SOURCE
#include <inttypes.h>
typedef uint8_t        u_int8_t;
typedef uint16_t       u_int16_t;
typedef uint32_t       u_int32_t;
typedef uint64_t       u_int64_t;
#else
/* solaris doesn't consistently define u_int*_t. */
typedef unsigned char  u_int8_t;
typedef unsigned short u_int16_t;
typedef unsigned int   u_int32_t;
typedef int            int32_t;
#endif
#else
#if (!defined(BSD)) || (BSD < 199306)
# include <sys/bitypes.h>
typedef int ssize_t;
#endif /* BSD */
#endif /* __svr4__ */
#endif

/* luckily ultrix is dead. as a result, we know what the sizes of
 * various types are forever. */
#ifdef ultrix 
typedef unsigned char  u_int8_t;
typedef unsigned short u_int16_t;
typedef unsigned int   u_int32_t;
typedef int            int32_t;
typedef int            ssize_t;
#endif

/* check for long long support. currently, i assume that if 64-bit
 * ints exist that their made available via long long */
#ifdef linux
#include <endian.h>
#else 
#if !(defined(BSD4_4) || defined(NO_LARGE_VOL_SUPPORT) || \
      defined(_ISOC9X_SOURCE))
typedef unsigned long long  u_int64_t;
#endif
#endif /* linux */

# ifndef BYTE_ORDER
#define LITTLE_ENDIAN	1234
#define BIG_ENDIAN	4321
#define PDP_ENDIAN	3412

#ifdef sun
#if defined(i386) || defined(_LITTLE_ENDIAN)
#define BYTE_ORDER	LITTLE_ENDIAN
#else i386
#define BYTE_ORDER	BIG_ENDIAN
#endif i386
#else
#ifdef MIPSEB
#define BYTE_ORDER	BIG_ENDIAN
#else
#ifdef MIPSEL
#define BYTE_ORDER	LITTLE_ENDIAN
#else
#error Like, what is your byte order, man?
#endif MIPSEL
#endif MIPSEB
#endif sun
# endif BYTE_ORDER

# ifndef ntohl
# if defined( sun ) || defined( ultrix ) || defined( _IBMR2 )
#if BYTE_ORDER == BIG_ENDIAN
#define ntohl(x)	(x)
#define ntohs(x)	(x)
#define htonl(x)	(x)
#define htons(x)	(x)

#else
#if defined( mips ) && defined( KERNEL )
#define	ntohl(x)	nuxi_l(x)
#define	ntohs(x)	nuxi_s(x)
#define	htonl(x)	nuxi_l(x)
#define	htons(x)	nuxi_s(x)

#else mips KERNEL
unsigned short ntohs(), htons();
unsigned long  ntohl(), htonl();

#endif mips KERNEL
#endif BYTE_ORDER
# endif sun ultrix _IBMR2
# endif ntohl

#  endif _ATALK_ENDIAN_H_
