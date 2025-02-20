/*
 * Copyright (c) 1990,1991 Regents of The University of Michigan.
 * All Rights Reserved.
 *
 * Permission to use, copy, modify, and distribute this software and
 * its documentation for any purpose and without fee is hereby granted,
 * provided that the above copyright notice appears in all copies and
 * that both that copyright notice and this permission notice appear
 * in supporting documentation, and that the name of The University
 * of Michigan not be used in advertising or publicity pertaining to
 * distribution of the software without specific, written prior
 * permission. This software is supplied as is without expressed or
 * implied warranties of any kind.
 *
 *	Research Systems Unix Group
 *	The University of Michigan
 *	c/o Mike Clark
 *	535 W. William Street
 *	Ann Arbor, Michigan
 *	+1-313-763-0525
 *	netatalk@itd.umich.edu
 */

#ifndef _ATALK_ADOUBLE_H
#define _ATALK_ADOUBLE_H

#include <unistd.h>

#if defined(sun) && defined(__svr4__)
#include </usr/ucbinclude/sys/file.h>
#else
#include <sys/file.h>
#endif
#include <fcntl.h>
#include <sys/cdefs.h>
#include <sys/types.h>
#include <netatalk/endian.h>

#ifdef _POSIX_MAPPED_FILES
#include <sys/mman.h>
#endif

/* XXX: this is the wrong place to put this. 
 * NOTE: as of 2.2.1, linux can't do a sendfile from a socket. */
#ifdef SENDFILE_FLAVOR_LINUX
#define HAVE_SENDFILE_READ
#define HAVE_SENDFILE_WRITE
#include <asm/unistd.h>

static inline int sendfile(int fdout, int fdin, off_t *off, size_t count)
{
  return syscall(__NR_sendfile, fdout, fdin, off, count);
}
#endif

#ifdef SENDFILE_FLAVOR_BSD
#define HAVE_SENDFILE_READ
#endif

/*
 * AppleDouble entry IDs. 
 */
#define ADEID_DFORK		1
#define ADEID_RFORK		2
#define ADEID_NAME		3
#define ADEID_COMMENT		4
#define ADEID_ICONBW		5
#define ADEID_ICONCOL		6
#define ADEID_FILEI		7  /* v1, replaced by: */
#define ADEID_FILEDATESI	8  /* this */
#define ADEID_FINDERI		9
#define ADEID_MACFILEI		10 /* we don't use this */
#define ADEID_PRODOSFILEI	11 /* we store prodos info here */
#define ADEID_MSDOSFILEI	12 /* we don't use this */
#define ADEID_SHORTNAME		13
#define ADEID_AFPFILEI		14 /* where the rest of the FILEI info goes */
#define ADEID_DID		15

#define ADEID_MAX		16

/* magic */
#define AD_APPLESINGLE_MAGIC 0x00051600
#define AD_APPLEDOUBLE_MAGIC 0x00051607
#define AD_MAGIC	AD_APPLEDOUBLE_MAGIC

/* version info */
#define AD_VERSION1	0x00010000
#define AD_VERSION2	0x00020000
#define AD_VERSION	AD_VERSION1

/* sizes of relevant entry bits */
#define AD_HEADER_LEN   26  /* everything up to the first entry header */
#define AD_ENTRY_LEN    12  /* size of a single entry header */

/* v1 field widths */
#define ADEDLEN_NAME        255
#define ADEDLEN_COMMENT     200
#define ADEDLEN_FILEI	    16
#define ADEDLEN_FINDERI	    32

/* v2 field widths */
#define ADEDLEN_FILEDATESI	16
#define ADEDLEN_SHORTNAME       12 /* length up to 8.3 */
#define ADEDLEN_AFPFILEI        4
#define ADEDLEN_MACFILEI        4
#define ADEDLEN_PRODOSFILEI     8
#define ADEDLEN_MSDOSFILEI      2
#define ADEDLEN_DID             4


#define AD_DATASZ1      589  
#define AD_DATASZ2      665  /* v1 + 4 new entries (entry desc. + entry) */
#if AD_VERSION == AD_VERSION1
#define AD_DATASZ	AD_DATASZ1 /* hold enough for the entries */
#else if AD_VERSION == AD_VERSION2
#define AD_DATASZ       AD_DATASZ2
#endif

/*
 * The header of the AppleDouble Header File looks like this:
 *
 *	NAME			SIZE
 *	====			====
 *	Magic			4
 *	Version			4
 * 	Home File System	16  (this becomes filler in ad v2)
 *	Number of Entries	2
 *	Entry Descriptors for each entry:
 *		Entry ID	4
 *		Offset		4
 *		Length		4
 */

struct ad_entry {
    u_int32_t	ade_off;
    u_int32_t	ade_len;
};

struct ad_fd {
    int		 adf_fd;
    u_int32_t	 adf_off;
    int		 adf_flags;
    struct flock adf_lock;
    struct ad_fd *adf_same;
};

struct adouble {
    u_int32_t		ad_magic;
    u_int32_t		ad_version;
    char		ad_filler[ 16 ];
    struct ad_entry	ad_eid[ ADEID_MAX ];
    char		ad_data[ AD_DATASZ ];
    struct ad_fd	ad_df, ad_hf;
    int                 ad_flags;
};

#define ADFLAGS_DF	  (1<<0)
#define ADFLAGS_HF	  (1<<1)
#define ADFLAGS_DIR	  (1<<2)
#define ADFLAGS_NOADOUBLE (1<<3)
#define ADFLAGS_V1COMPAT  (1<<4)

/* lock flags */
#define ADLOCK_CLR      0x0
#define ADLOCK_RD       0x1
#define ADLOCK_WR       0x2

/* time stuff. we overload the bits a little.  */
#define AD_DATE_CREATE	       0
#define AD_DATE_MODIFY	       4
#define AD_DATE_BACKUP	       8
#define AD_DATE_ACCESS        12 
#define AD_DATE_MASK          (AD_DATE_CREATE | AD_DATE_MODIFY | \
			       AD_DATE_BACKUP | AD_DATE_ACCESS)
#define AD_DATE_UNIX          (1 << 10)
#define AD_DATE_START         htonl(0x80000000)
#define AD_DATE_DELTA         946684800
#define AD_DATE_FROM_UNIX(x)  htonl((x) - AD_DATE_DELTA)
#define AD_DATE_TO_UNIX(x)    (ntohl(x) + AD_DATE_DELTA)
 
/* private AFPFileInfo bits */
#define AD_AFPFILEI_OWNER       (1 << 0) /* any owner */
#define AD_AFPFILEI_GROUP       (1 << 1) /* ignore group */
#define AD_AFPFILEI_BLANKACCESS (1 << 2) /* blank access permissions */

#define ad_dfileno(ad)		((ad)->ad_df.adf_fd)
#define ad_dlock(ad)            ((ad)->ad_df.adf_lock)
#define ad_hfileno(ad)		((ad)->ad_hf.adf_fd)
#define ad_hlock(ad)            ((ad)->ad_hf.adf_lock)
#define ad_getversion(ad)	((ad)->ad_version)

/* XXX: this should be changed to deal with arbitrary entries. */
#define ad_getentrylen(ad,eid)	((ad)->ad_eid[(eid)].ade_len)
#define ad_setentrylen(ad,eid,len) \
	((ad)->ad_eid[(eid)].ade_len = (len))
#define ad_getentryoff(ad,eid)  ((ad)->ad_eid[(eid)].ade_off)
#define ad_entry(ad,eid)	(((ad)->ad_eid[(eid)].ade_off + \
	(ad)->ad_eid[(eid)].ade_len > AD_DATASZ ) ? 0 : \
	(caddr_t)(ad)->ad_data + (ad)->ad_eid[(eid)].ade_off)
#define ad_getoflags(ad,adf)	(((adf)&ADFLAGS_HF) ? \
	(ad)->ad_hf.adf_flags : (ad)->ad_df.adf_flags)

/* ad_flush.c */
extern void ad_rebuild_header __P((struct adouble *));
extern int ad_flush __P((struct adouble *, int));

/* ad_lock.c */
extern int ad_flock_lock __P((struct adouble *, const u_int32_t /*eid*/,
			      const int /*type*/, off_t /*offset*/,
			      const int /*endflag*/, const off_t /*len*/));
extern int ad_fcntl_lock __P((struct adouble *, const u_int32_t /*eid*/,
			      const int /*type*/, off_t /*offset*/,
			      const int /*endflag*/, const off_t /*len*/));

extern int ad_flock_tmplock __P((struct adouble *, const u_int32_t /*eid*/,
				 const int /*type*/, off_t /*offset*/,
				 const int /*end*/, const off_t /*len*/));
extern int ad_fcntl_tmplock __P((struct adouble *, const u_int32_t /*eid*/,
				 const int /*type*/, off_t /*offset*/,
				 const int /*end*/, const off_t /*len*/));

#ifdef USE_FCNTL_LOCKS
#define ad_lock ad_fcntl_lock
#define ad_tmplock ad_fcntl_tmplock
#else
#define ad_lock ad_flock_lock
#define ad_tmplock ad_flock_tmplock
#endif

/* ad_open.c */
extern char *ad_path __P((char *, int));
extern int ad_mode __P((char *, int));
extern int ad_mkdir __P((char *, int));
extern int ad_open __P((char *, int, int, int, struct adouble *));
extern int ad_refresh __P((struct adouble *));

/* ad_read.c/ad_write.c */
extern ssize_t ad_read __P((struct adouble *, const u_int32_t, 
			    const u_int32_t, char *, const size_t));
extern ssize_t ad_write __P((struct adouble *, const u_int32_t, u_int32_t,
			     const int, const char *, const size_t));
extern int ad_dtruncate __P((struct adouble *, const size_t));
extern int ad_rtruncate __P((struct adouble *, const size_t));

/* ad_size.c */
extern off_t ad_size __P((const struct adouble *, const u_int32_t ));

/* ad_mmap.c */
extern void *ad_mmapread __P((struct adouble *, const u_int32_t,
			      const off_t, const size_t));
extern void *ad_mmapwrite __P((struct adouble *, const u_int32_t,
			       const off_t, const int, const size_t));
#define ad_munmap(buf, len)  (munmap((buf), (len)))

/* ad_date.c */
extern int ad_setdate __P((const struct adouble *, unsigned int, u_int32_t));
extern int ad_getdate __P((const struct adouble *, unsigned int, u_int32_t *));

/* ad_attr.c */
extern int ad_setattr __P((const struct adouble *, const u_int16_t));
extern int ad_getattr __P((const struct adouble *, u_int16_t *));

#ifdef HAVE_SENDFILE_READ
ssize_t ad_readfile __P((const struct adouble *, const int, 
			 const int, off_t, const size_t));
#endif

#if 0
#ifdef HAVE_SENDFILE_WRITE
ssize_t ad_writefile __P((struct adouble *, const int, 
			  const int, off_t, const int, const size_t));
#endif
#endif
     
#endif
