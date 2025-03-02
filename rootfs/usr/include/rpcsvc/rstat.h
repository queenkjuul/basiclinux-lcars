#ifndef FSCALE
/*
 * Scale factor for scaled integers used to count load averages.
 */
#define FSHIFT  8               /* bits to right of fixed binary point */
#define FSCALE  (1<<FSHIFT)

#endif /* ndef FSCALE */
#define CPUSTATES 4
#define DK_NDRIVE 4

struct rstat_timeval {
	u_int tv_sec;
	u_int tv_usec;
};
typedef struct rstat_timeval rstat_timeval;
bool_t xdr_rstat_timeval();


struct statstime {
	int cp_time[CPUSTATES];
	int dk_xfer[DK_NDRIVE];
	u_int v_pgpgin;
	u_int v_pgpgout;
	u_int v_pswpin;
	u_int v_pswpout;
	u_int v_intr;
	int if_ipackets;
	int if_ierrors;
	int if_oerrors;
	int if_collisions;
	u_int v_swtch;
	int avenrun[3];
	rstat_timeval boottime;
	rstat_timeval curtime;
	int if_opackets;
};
typedef struct statstime statstime;
bool_t xdr_statstime();


struct statsswtch {
	int cp_time[CPUSTATES];
	int dk_xfer[DK_NDRIVE];
	u_int v_pgpgin;
	u_int v_pgpgout;
	u_int v_pswpin;
	u_int v_pswpout;
	u_int v_intr;
	int if_ipackets;
	int if_ierrors;
	int if_oerrors;
	int if_collisions;
	u_int v_swtch;
	u_int avenrun[3];
	rstat_timeval boottime;
	int if_opackets;
};
typedef struct statsswtch statsswtch;
bool_t xdr_statsswtch();


struct stats {
	int cp_time[CPUSTATES];
	int dk_xfer[DK_NDRIVE];
	u_int v_pgpgin;
	u_int v_pgpgout;
	u_int v_pswpin;
	u_int v_pswpout;
	u_int v_intr;
	int if_ipackets;
	int if_ierrors;
	int if_oerrors;
	int if_collisions;
	int if_opackets;
};
typedef struct stats stats;
bool_t xdr_stats();


#define RSTATPROG ((u_long)100001)
#define RSTATVERS_TIME ((u_long)3)
#define RSTATPROC_STATS ((u_long)1)
extern statstime *rstatproc_stats_3();
#define RSTATPROC_HAVEDISK ((u_long)2)
extern u_int *rstatproc_havedisk_3();
#define RSTATVERS_SWTCH ((u_long)2)
extern statsswtch *rstatproc_stats_2();
extern u_int *rstatproc_havedisk_2();
#define RSTATVERS_ORIG ((u_long)1)
extern stats *rstatproc_stats_1();
extern u_int *rstatproc_havedisk_1();

