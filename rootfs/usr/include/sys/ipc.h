#ifndef _SYS_IPC_H
#define _SYS_IPC_H

#include <features.h>

#include <linux/ipc.h>

__BEGIN_DECLS

extern key_t ftok __P((char *__pathname, char __proc_id));
extern int __ipc __P((int __call, int _first, int __second,
			int __third, void * __ptr));

__END_DECLS

#endif /* _SYS_IPC_H */
