/* 
 * interface for database access to cnids. i do it this way to abstract
 * things a bit in case we want to change the underlying implementation.
 */

#ifndef INCLUDE_ATALK_CNID_H
#define INCLUDE_ATALK_CNID_H 1

#include <sys/cdefs.h>
#include <sys/stat.h>
#include <unistd.h>

#include <netatalk/endian.h>

typedef u_int32_t cnid_t;

/* cnid_open.c */
void *cnid_open __P((const char *));

/* cnid_close.c */
void cnid_close __P((void *));

/* cnid_add.c */
cnid_t cnid_add __P((void *, const struct stat *, const cnid_t,
		     const char *, const int, cnid_t));

/* cnid_get.c */
cnid_t cnid_get __P((void *, const cnid_t, const char *, const int)); 
char *cnid_resolve __P((void *, cnid_t *)); 
cnid_t cnid_lookup __P((void *, const struct stat *, const cnid_t,
			const char *, const int));

/* cnid_update.c */
int cnid_update __P((void *, const cnid_t, const struct stat *, const cnid_t,
		     const char *, int));

/* cnid_delete.c */
int cnid_delete __P((void *, const cnid_t));

/* cnid_nextid.c */
cnid_t cnid_nextid __P((void *));

#endif /* include/atalk/cnid.h */
