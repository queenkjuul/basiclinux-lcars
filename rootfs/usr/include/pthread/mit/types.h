#ifndef _PTHREAD_MIT_TYPES_H
#define _PTHREAD_MIT_TYPES_H

#include <pthread/mit/xtypes.h>
#include <pthread/mit/sys/types.h>
/*
#include <pthread/ac-types.h>
*/

#if !defined (pthread_va_list) && defined (__GNUC__)
#define __need_va_list
#include <stdarg.h>
#define pthread_va_list __gnuc_va_list
#endif /* pthread_va_list, __GNUC__ */

/* OSF/1 does it this way.  */
#if !defined (pthread_va_list) && defined (pthread_have_va_list_h)
#ifndef _VA_LIST
#define _HIDDEN_VA_LIST
#include <va_list.h>
#define pthread_va_list __va_list
#else
/* va_list has already been defined */
#define pthread_va_list va_list
#endif
#endif

/* If all else fails... */
#ifndef pthread_va_list
#include <stdarg.h>
#define pthread_va_list va_list
#endif

#endif /* _PTHREAD_MIT_TYPES_H */
