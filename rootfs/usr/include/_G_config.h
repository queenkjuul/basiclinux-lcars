/* AUTOMATICALLY GENERATED; DO NOT EDIT! */ 
#ifndef _G_config_h
#define _G_config_h

#define _LINUX_C_LIB_VERSION		"5.4.46"
#define _LINUX_C_LIB_VERSION_MAJOR	5
#define _LINUX_C_LIB_VERSION_MINOR	4
#define _LINUX_C_LIB_VERSION_SUBMINOR	46

#define _G_LIB_VERSION "2.7.2"

#ifdef __ELF__
#define _G_NAMES_HAVE_UNDERSCORE 0
#define _G_VTABLE_LABEL_PREFIX "_vt."
#else /* __ELF__ */
#define _G_NAMES_HAVE_UNDERSCORE 1
#define _G_VTABLE_LABEL_PREFIX "__vt$"
#endif /* __ELF__ */

#define _G_VTABLE_LABEL_HAS_LENGTH 1
#define _G_HAVE_ST_BLKSIZE 1
typedef long _G_clock_t;
typedef unsigned short _G_dev_t;
typedef long int _G_fpos_t;
typedef unsigned short _G_gid_t;
typedef unsigned long _G_ino_t;
typedef unsigned short _G_mode_t;
typedef unsigned short _G_nlink_t;
typedef long _G_off_t;
typedef int _G_pid_t;
#ifndef __PTRDIFF_TYPE__
#define __PTRDIFF_TYPE__ int
#endif
typedef __PTRDIFF_TYPE__ _G_ptrdiff_t;
typedef unsigned long _G_sigset_t;
#ifndef __SIZE_TYPE__
#define __SIZE_TYPE__ unsigned int
#endif
typedef __SIZE_TYPE__ _G_size_t;
typedef long _G_time_t;
typedef unsigned short _G_uid_t;
typedef long int _G_wchar_t;
typedef int _G_ssize_t;
typedef int /* default */ _G_wint_t;
typedef void * _G_va_list;
#define _G_signal_return_type void
#define _G_sprintf_return_type int

#if __GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 7)
typedef          int   _G_int8_t __attribute__((__mode__(__QI__)));
typedef unsigned int  _G_uint8_t __attribute__((__mode__(__QI__)));
typedef          int  _G_int16_t __attribute__((__mode__(__HI__)));
typedef unsigned int _G_uint16_t __attribute__((__mode__(__HI__)));
typedef          int  _G_int32_t __attribute__((__mode__(__SI__)));
typedef unsigned int _G_uint32_t __attribute__((__mode__(__SI__)));
typedef          int  _G_int64_t __attribute__((__mode__(__DI__)));
typedef unsigned int _G_uint64_t __attribute__((__mode__(__DI__)));
#else
typedef  short  _G_int16_t;
typedef unsigned short _G_uint16_t;
typedef  int  _G_int32_t;
typedef unsigned int _G_uint32_t;
#endif

#define _G_BUFSIZ 1024
#define _G_FOPEN_MAX 256
#define _G_FILENAME_MAX 1024
#define _G_NULL 0 /* default */
#if defined (__cplusplus) || defined (__STDC__)
#define _G_ARGS(ARGLIST) ARGLIST
#else
#define _G_ARGS(ARGLIST) ()
#endif
#if !defined (__GNUG__) || defined (__STRICT_ANSI__)
#define _G_NO_NRV
#endif
#if !defined (__GNUG__)
#define _G_NO_EXTERN_TEMPLATES
#endif
#define _G_HAVE_ATEXIT 1
#define _G_HAVE_SYS_RESOURCE 1
#define _G_HAVE_SYS_TIMES 1
#define _G_HAVE_SYS_SOCKET 1
#define _G_HAVE_SYS_CDEFS 1
#define _G_HAVE_SYS_WAIT 1
#define _G_HAVE_UNISTD 1
#define _G_HAVE_DIRENT 1
#define _G_HAVE_CURSES 1
#define _G_HAVE_FEATURES 1
#define _G_MATH_H_INLINES 0
#if defined(__GNUG__) && defined(__GNUC__) && (__GNUC__ > 2 || \
	(__GNUC__ == 2 && __GNUC_MINOR__ >= 6))
#define _G_HAVE_BOOL 1
#else
#define _G_HAVE_BOOL 0
#endif

#define	_G_HAVE_LONG_DOUBLE_IO 1
#define _G_HAVE_PRINTF_FP 1
#define _G_HAVE_MMAP 1

#undef NULL
#if defined __GNUG__ && \
   (__GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 8))
#define __need_NULL
#include <stddef.h>
#else
# if !defined(__cplusplus)                                          
#  define NULL ((void*)0)
# else                                                    
#  define NULL (0)                                                     
# endif
#endif

#endif /* !_G_config_h */
