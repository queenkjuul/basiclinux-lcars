#ifndef _ATALK_UTIL_H
#define _ATALK_UTIL_H 1

#include <sys/cdefs.h>
#include <unistd.h>
#include <netatalk/at.h>

extern unsigned const char _diacasemap[], _dialowermap[];

#define diatolower(x)     _dialowermap[(x)]
#define diatoupper(x)     _diacasemap[(x)]
extern int atalk_aton     __P((char *, struct at_addr *));
extern int strdiacasecmp  __P((unsigned char *, unsigned char *));
extern int strndiacasecmp __P((unsigned char *, unsigned char *, int));
extern int server_lock    __P((char * /*program*/, char * /*file*/, 
			       int /*debug*/));
#define server_unlock(x)  (unlink(x))
#endif
