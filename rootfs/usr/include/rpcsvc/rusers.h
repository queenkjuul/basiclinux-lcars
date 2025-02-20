/*
 * Find out about remote users
 */
#define RUSERS_MAXUSERLEN 32
#define RUSERS_MAXLINELEN 32
#define RUSERS_MAXHOSTLEN 257

struct rusers_utmp {
	char *ut_user;
	char *ut_line;
	char *ut_host;
	int ut_type;
	int ut_time;
	u_int ut_idle;
};
typedef struct rusers_utmp rusers_utmp;
bool_t xdr_rusers_utmp();


typedef struct {
	u_int utmp_array_len;
	rusers_utmp *utmp_array_val;
} utmp_array;
bool_t xdr_utmp_array();


/*
 * Values for ut_type field above.
 */
#define RUSERS_EMPTY 0
#define RUSERS_RUN_LVL 1
#define RUSERS_BOOT_TIME 2
#define RUSERS_OLD_TIME 3
#define RUSERS_NEW_TIME 4
#define RUSERS_INIT_PROCESS 5
#define RUSERS_LOGIN_PROCESS 6
#define RUSERS_USER_PROCESS 7
#define RUSERS_DEAD_PROCESS 8
#define RUSERS_ACCOUNTING 9

#define RUSERSPROG ((u_long)100002)
#define RUSERSVERS_3 ((u_long)3)
#define RUSERSPROC_NUM ((u_long)1)
extern int *rusersproc_num_3();
#define RUSERSPROC_NAMES ((u_long)2)
extern utmp_array *rusersproc_names_3();
#define RUSERSPROC_ALLNAMES ((u_long)3)
extern utmp_array *rusersproc_allnames_3();



#ifdef	__cplusplus
extern "C" {
#endif

/*
 * The following structures are used by version 2 of the rusersd protocol.
 * They were not developed with rpcgen, so they do not appear as RPCL.
 */

#define	RUSERSVERS_IDLE 2
#define	RUSERSVERS 3		/* current version */
#define	MAXUSERS 100

/*
 * This is the structure used in version 2 of the rusersd RPC service.
 * It corresponds to the utmp structure for BSD sytems.
 */
struct ru_utmp {
	char	ut_line[8];		/* tty name */
	char	ut_name[8];		/* user id */
	char	ut_host[16];		/* host name, if remote */
	long	ut_time;		/* time on */
};

struct utmparr {
       struct ru_utmp **uta_arr;
       int uta_cnt;
};
typedef struct utmparr utmparr;
int xdr_utmparr();

struct utmpidle {
	struct ru_utmp ui_utmp;
	unsigned ui_idle;
};

struct utmpidlearr {
	struct utmpidle **uia_arr;
	int uia_cnt;
};

int xdr_utmpidlearr();

#ifdef	__cplusplus
}
#endif
