#ifndef _SCHED_H
#define _SCHED_H

/*
 *   Header file <sched.h> specified by IEEE Std 1003.1b-1993
 *   in section 13 (execution scheduling).
 *
 *   (C) Markus Kuhn, 1996
 *
 */

#include <features.h>
#include <sys/types.h>
#include <sys/time.h>

#define SCHED_OTHER    0
#define SCHED_FIFO     1
#define SCHED_RR       2

struct sched_param
{
  int sched_priority;     /* Process execution scheduling priority */
};

__BEGIN_DECLS

extern int sched_setparam __P((pid_t __pid,
		const struct sched_param *__param));
extern int sched_getparam __P((pid_t __pid,
		struct sched_param *__param));
extern int sched_setscheduler __P((pid_t __pid, int __policy,
	const struct sched_param *__param));
extern int sched_getscheduler __P((pid_t __pid));
extern int sched_yield __P((void));
extern int sched_get_priority_max __P((int __policy));
extern int sched_get_priority_min __P((int __policy));
extern int sched_rr_get_interval __P((pid_t __pid,
		struct timespec *interval));

__END_DECLS

#endif /* _SCHED_H */
