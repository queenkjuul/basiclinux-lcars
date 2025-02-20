#ifndef _M68K_SYSCALL_H
#define _M68K_SYSCALL_H

#ifdef PTHREADS_SYSCALL

#define _syscall0(type,name) \
type name(void) \
{ \
register long __res __asm__ ("%d0"); \
__asm__ __volatile__ ("trap  #0" \
                      : "=g" (__res) \
                      : "0" (SYS_##name) \
		      : "%d0"); \
return (type) __res; \
}

#define _syscall1(type,name,atype,a) \
type name(atype a) \
{ \
register long __res __asm__ ("%d0"); \
__asm__ __volatile__ ("movel %2,%/d1\n\t" \
                      "trap  #0" \
                      : "=g" (__res) \
                      : "0" (SYS_##name), "g" ((long)(a)) \
                      : "%d0", "%d1"); \
return (type) __res; \
}

#define _syscall2(type,name,atype,a,btype,b) \
type name(atype a,btype b) \
{ \
register long __res __asm__ ("%d0"); \
__asm__ __volatile__ ("movel %2,%/d1\n\t" \
		      "movel %3,%/d2\n\t" \
                      "trap  #0" \
                      : "=g" (__res) \
                      : "0" (SYS_##name), "g" ((long)(a)), \
                                          "g" ((long)(b)) \
                      : "%d0", "%d1", "%d2"); \
return (type) __res; \
}

#define _syscall3(type,name,atype,a,btype,b,ctype,c) \
type name(atype a,btype b,ctype c) \
{ \
register long __res __asm__ ("%d0"); \
__asm__ __volatile__ ("movel %2,%/d1\n\t" \
		      "movel %3,%/d2\n\t" \
		      "movel %4,%/d3\n\t" \
                      "trap  #0" \
                      : "=g" (__res) \
                      : "0" (SYS_##name), "g" ((long)(a)), \
                                          "g" ((long)(b)), \
                                          "g" ((long)(c)) \
                      : "%d0", "%d1", "%d2", "%d3"); \
return (type) __res; \
}

#define _syscall4(type,name,atype,a,btype,b,ctype,c,dtype,d) \
type name (atype a, btype b, ctype c, dtype d) \
{ \
register long __res __asm__ ("%d0"); \
__asm__ __volatile__ ("movel %2,%/d1\n\t" \
		      "movel %3,%/d2\n\t" \
		      "movel %4,%/d3\n\t" \
		      "movel %5,%/d4\n\t" \
                      "trap  #0" \
                      : "=g" (__res) \
                      : "0" (SYS_##name), "g" ((long)(a)), \
                                          "g" ((long)(b)), \
					  "g" ((long)(c)), \
					  "g" ((long)(d))  \
                      : "%d0", "%d1", "%d2", "%d3", "%d4"); \
return (type) __res; \
}

#define _syscall5(type,name,atype,a,btype,b,ctype,c,dtype,d,etype,e) \
type name (atype a,btype b,ctype c,dtype d,etype e) \
{ \
register long __res __asm__ ("%d0"); \
__asm__ __volatile__ ("movel %2,%/d1\n\t" \
		      "movel %3,%/d2\n\t" \
		      "movel %4,%/d3\n\t" \
		      "movel %5,%/d4\n\t" \
		      "movel %6,%/d5\n\t" \
                      "trap  #0" \
                      : "=g" (__res) \
                      : "0" (SYS_##name), "g" ((long)(a)), \
                                          "g" ((long)(b)), \
					  "g" ((long)(c)), \
					  "g" ((long)(d)), \
					  "g" ((long)(e))  \
                      : "%d0", "%d1", "%d2", "%d3", "%d4", "%d5"); \
return (type) __res; \
}

#else /* PTHREADS_SYSCALL */

#define _syscall0(type,name) \
type name(void) \
{ \
long __res; \
register long __d0 __asm__ ("%d0"); \
__asm__ __volatile__ ("trap  #0" \
                      : "=g" (__d0) \
                      : "0" (SYS_##name) \
		      : "%d0"); \
__res = __d0; \
if (__check_errno(__res)) \
	return (type) __res; \
errno = -__res; \
return -1; \
}

#define _syscall1(type,name,atype,a) \
type name(atype a) \
{ \
long __res; \
register long __d0 __asm__ ("%d0"); \
__asm__ __volatile__ ("movel %2,%/d1\n\t" \
                      "trap  #0" \
                      : "=g" (__d0) \
                      : "0" (SYS_##name), "g" ((long)(a)) \
                      : "%d0", "%d1"); \
__res = __d0; \
if (__check_errno(__res)) \
	return (type) __res; \
errno = -__res; \
return -1; \
}

#define _syscall2(type,name,atype,a,btype,b) \
type name(atype a,btype b) \
{ \
long __res; \
register long __d0 __asm__ ("%d0"); \
__asm__ __volatile__ ("movel %2,%/d1\n\t" \
		      "movel %3,%/d2\n\t" \
                      "trap  #0" \
                      : "=g" (__d0) \
                      : "0" (SYS_##name), "g" ((long)(a)), \
                                          "g" ((long)(b)) \
                      : "%d0", "%d1", "%d2"); \
__res = __d0; \
if (__check_errno(__res)) \
	return (type) __res; \
errno = -__res; \
return -1; \
}

#define _syscall3(type,name,atype,a,btype,b,ctype,c) \
type name(atype a,btype b,ctype c) \
{ \
long __res; \
register long __d0 __asm__ ("%d0"); \
__asm__ __volatile__ ("movel %2,%/d1\n\t" \
		      "movel %3,%/d2\n\t" \
		      "movel %4,%/d3\n\t" \
                      "trap  #0" \
                      : "=g" (__d0) \
                      : "0" (SYS_##name), "g" ((long)(a)), \
                                          "g" ((long)(b)), \
                                          "g" ((long)(c)) \
                      : "%d0", "%d1", "%d2", "%d3"); \
__res = __d0; \
if (__check_errno(__res)) \
	return (type) __res; \
errno = -__res; \
return -1; \
}

#define _syscall4(type,name,atype,a,btype,b,ctype,c,dtype,d) \
type name (atype a, btype b, ctype c, dtype d) \
{ \
long __res; \
register long __d0 __asm__ ("%d0"); \
__asm__ __volatile__ ("movel %2,%/d1\n\t" \
		      "movel %3,%/d2\n\t" \
		      "movel %4,%/d3\n\t" \
		      "movel %5,%/d4\n\t" \
                      "trap  #0" \
                      : "=g" (__d0) \
                      : "0" (SYS_##name), "g" ((long)(a)), \
                                          "g" ((long)(b)), \
					  "g" ((long)(c)), \
					  "g" ((long)(d))  \
                      : "%d0", "%d1", "%d2", "%d3", "%d4"); \
__res = __d0; \
if (__check_errno(__res)) \
	return (type) __res; \
errno = -__res; \
return -1; \
}

#define _syscall5(type,name,atype,a,btype,b,ctype,c,dtype,d,etype,e) \
type name (atype a,btype b,ctype c,dtype d,etype e) \
{ \
long __res; \
register long __d0 __asm__ ("%d0"); \
__asm__ __volatile__ ("movel %2,%/d1\n\t" \
		      "movel %3,%/d2\n\t" \
		      "movel %4,%/d3\n\t" \
		      "movel %5,%/d4\n\t" \
		      "movel %6,%/d5\n\t" \
                      "trap  #0" \
                      : "=g" (__d0) \
                      : "0" (SYS_##name), "g" ((long)(a)), \
                                          "g" ((long)(b)), \
					  "g" ((long)(c)), \
					  "g" ((long)(d)), \
					  "g" ((long)(e))  \
                      : "%d0", "%d1", "%d2", "%d3", "%d4", "%d5"); \
__res = __d0; \
if (__check_errno(__res)) \
	return (type) __res; \
errno = -__res; \
return -1; \
}

#endif /* PTHREADS_SYSCALL */

#endif /* _M68K_SYSCALL_H */
