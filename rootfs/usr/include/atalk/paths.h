#ifndef ATALK_PATHS_H
#define ATALK_PATHS_H 1

/* we need a way of concatenating strings */
#ifdef __STDC__
#define ATALKPATHCAT(a,b) a##b
#else
#define ATALKPATHCAT(a,b) a/**/b
#endif


/* lock file path. this should be re-organized a bit. */
#ifndef _PATH_LOCKDIR
#ifdef BSD4_4
#define _PATH_LOCKDIR           "/var/spool/lock/"
#else
#ifdef linux
#define _PATH_LOCKDIR           "/var/lock/"
#else
#define _PATH_LOCKDIR           "/var/spool/locks/"
#endif /* linux */
#endif /* BSD4_4 */
#endif

/*
 * papd paths
 */
#define _PATH_PAPDPRINTCAP	"/etc/printcap"
#ifdef ultrix
#define _PATH_PAPDSPOOLDIR	"/usr/spool/lpd"
#else ultrix
#define _PATH_PAPDSPOOLDIR	"/var/spool/lpd"
#endif ultrix
#ifdef BSD4_4
#define _PATH_DEVPRINTER	"/var/run/printer"
#else BSD4_4
#define _PATH_DEVPRINTER	"/dev/printer"
#endif BSD4_4

/*
 * atalkd paths
 */
#define _PATH_ATALKDEBUG	"/tmp/atalkd.debug"
#define _PATH_ATALKDTMP		"atalkd.tmp"
#define _PATH_ATALKDLOCK	ATALKPATHCAT(_PATH_LOCKDIR,"atalkd")

/*
 * psorder paths
 */
#define _PATH_TMPPAGEORDER	"/tmp/psorderXXXXXX"
#define _PATH_PAPDLOCK		ATALKPATHCAT(_PATH_LOCKDIR,"papd")

/*
 * afpd paths
 */
#define _PATH_AFPTKT		"/tmp/AFPtktXXXXXX"
#define _PATH_AFPDLOCK		ATALKPATHCAT(_PATH_LOCKDIR,"afpd")

#endif /* atalk/paths.h */
