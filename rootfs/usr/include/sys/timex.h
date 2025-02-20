#ifndef _SYS_TIMEX_H
#define _SYS_TIMEX_H

#include <features.h>
#include <sys/types.h>
#include <sys/time.h>
#include <linux/timex.h>

struct ntptimeval {
  struct timeval time;	/* current time */
  long maxerror;	/* maximum error (usec) */
  long esterror;	/* estimated error (usec) */
};

__BEGIN_DECLS

extern int __adjtimex __P ((struct timex * __ntx));
extern int __ntp_gettime __P ((struct ntptimeval * __ntv)); 

__END_DECLS

#endif
