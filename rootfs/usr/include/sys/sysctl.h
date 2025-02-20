#ifndef _SYS_SYSCTL_H
#define _SYS_SYSCTL_H

#include <features.h>
#include <sys/types.h>

__BEGIN_DECLS

extern int sysctl __P((int *__name, int __nlen, void *__oldval,
	size_t *__oldlenp, void *__newval, size_t __newlen));

__END_DECLS

#endif /* _SYS_SYSCTL_H */
