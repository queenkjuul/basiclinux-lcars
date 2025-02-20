/* utmp.h for Linux, by poe@daimi.aau.dk */

#ifndef UTMP_H
#define UTMP_H

#include <features.h>
#include <sys/types.h>
#include <sys/time.h>
#include <time.h>
#include <sys/wait.h>
#include <paths.h>

#define UTMP_FILE	_PATH_UTMP
#define WTMP_FILE	_PATH_WTMP

#define UTMP_FILENAME	UTMP_FILE
#define WTMP_FILENAME	WTMP_FILE

/* defines for the ut_type field */
#define UT_UNKNOWN	0

#define RUN_LVL		1
#define BOOT_TIME	2
#define NEW_TIME	3
#define OLD_TIME	4

#define INIT_PROCESS	5
#define LOGIN_PROCESS	6
#define USER_PROCESS	7
#define DEAD_PROCESS	8


/* size of user name */
#if 1
#define UT_LINESIZE	12
#define UT_NAMESIZE	8
#define UT_HOSTSIZE	16

struct utmp
{
	short	ut_type;	/* type of login */
	pid_t	ut_pid;		/* pid of login-process */
	char	ut_line[UT_LINESIZE];	/* devicename of tty -"/dev/", null-term */
	char	ut_id[4];	/* inittab id */
	time_t	ut_time;	/* login time */
	char	ut_user[UT_NAMESIZE];	/* username, not null-term */
	char	ut_host[UT_HOSTSIZE];	/* hostname for remote login... */
	long	ut_addr;	/* IP addr of remote host */
};

#else

#define UT_LINESIZE	32
#define UT_NAMESIZE	32
#define UT_HOSTSIZE	256

struct utmp
{
	short	ut_type;	/* type of login */
	pid_t	ut_pid;		/* pid of login-process */
	char	ut_line[UT_LINESIZE];	/* devicename of tty -"/dev/", null-term */
	char	ut_id[4];	/* inittab id */
	char	ut_user[UT_NAMESIZE];	/* username, not null-term */
	char	ut_host[UT_HOSTSIZE];	/* hostname for remote login... */
	int	ut_exit;	/* process termination/exit status */
	struct	timeval ut_tv;	/* time entry was made */
	long	ut_session;	/* session ID, used for windowing */
	long	ut_addr;	/* IP addr of remote host */
	char	pad [8];	/* reserved for future use */
};

#define ut_time ut_tv.tv_sec 

#endif

#define ut_name ut_user

__BEGIN_DECLS

extern void		setutent __P ((void));
extern void		utmpname __P ((__const char *));
extern struct utmp	*getutent __P ((void));
extern struct utmp	*getutid __P ((struct utmp *));
extern struct utmp 	*getutline __P ((struct utmp *));
extern void		pututline __P ((struct utmp *));
extern struct utmp	*_getutline __P ((struct utmp *));
extern void		endutent __P ((void));

__END_DECLS

#endif	
