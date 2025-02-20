#ifndef _SYS_PROCFS_H
#define _SYS_PROCFS_H

/* Are we included by gdb/bfd and using the right compiler? gdb
   has be changed so that we have to do this. */
#if defined(__ELF__) && defined(__linux__)

/* We just need it for gdb/bfd. */
#include <linux/elfcore.h>

#endif /* __ELF__ && __linux__ */

#endif /* _SYS_PROCFS_H */
