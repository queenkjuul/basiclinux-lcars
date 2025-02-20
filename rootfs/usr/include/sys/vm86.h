#ifndef _SYS_VM86_H
#define _SYS_VM86_H

#if defined(__i386__)

#include <features.h>
#include <asm/vm86.h>

__BEGIN_DECLS

extern int vm86old __P ((struct vm86_struct * __info));
extern int vm86 __P ((unsigned long __subfunction, struct vm86plus_struct * __info));

__END_DECLS

#else

# error This architecture is not supported by <sys/vm86.h>

#endif

#endif /*_SYS_VM86_H */
