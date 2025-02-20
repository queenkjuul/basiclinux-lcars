#ifndef _SYS_UTSNAME_H
#define _SYS_UTSNAME_H

#include <features.h>
#include <sys/param.h>

#ifdef __SVR4_I386_ABI_L1__

#define _SYS_NMLN 257

struct utsname {
	char sysname[_SYS_NMLN];
	char nodename[_SYS_NMLN];
	char release[_SYS_NMLN];
	char version[_SYS_NMLN];
	char machine[_SYS_NMLN-65];
	char domainname[65];	/* Kludge to allow linux domain name to work
				   with SVR4 ABI. */
};

#else /* !__SVR4_I386_ABI_L1__ */

#define _SYS_NMLN 65

struct utsname {
	char sysname[_SYS_NMLN];
	char nodename[_SYS_NMLN];
	char release[_SYS_NMLN];
	char version[_SYS_NMLN];
	char machine[_SYS_NMLN];
	char domainname[_SYS_NMLN];
};

#endif /* !__SVR4_I386_ABI_L1__ */

/* Bad namespace pollution. Some programs use it :-(. H.J.*/
#define SYS_NMLN _SYS_NMLN

__BEGIN_DECLS

extern int uname __P ((struct utsname * __utsbuf));
extern int __uname __P ((struct utsname * __utsbuf));

__END_DECLS

#endif
