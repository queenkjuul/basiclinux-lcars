#ifndef _LIBELF_H
#define	_LIBELF_H

#include <features.h>
#include <sys/types.h>
#include <elf.h>

__BEGIN_DECLS

/* commands */
typedef enum 
{
  ELF_C_NULL = 0,	/* must be first, 0 */
  ELF_C_READ,
  ELF_C_WRITE,
  ELF_C_CLR,
  ELF_C_SET,
  ELF_C_FDDONE,
  ELF_C_FDREAD,
  ELF_C_RDWR,
  ELF_C_NUM		/* must be last */
} Elf_Cmd;


/* flags */
#define	ELF_F_DIRTY	0x1
#define	ELF_F_LAYOUT	0x4


/* file types */
typedef enum
{
  ELF_K_NONE = 0,	/* must be first, 0 */
  ELF_K_AR,
  ELF_K_COFF,
  ELF_K_ELF,
  ELF_K_NUM		/* must be last */
} Elf_Kind;


/* translation types */
typedef enum
{
  ELF_T_BYTE = 0,	/* must be first, 0 */
  ELF_T_ADDR,
  ELF_T_DYN,
  ELF_T_EHDR,
  ELF_T_HALF,
  ELF_T_OFF,
  ELF_T_PHDR,
  ELF_T_RELA,
  ELF_T_REL,
  ELF_T_SHDR,
  ELF_T_SWORD,
  ELF_T_SYM,
  ELF_T_WORD,
  ELF_T_NUM		/* must be last */
} Elf_Type;


/* Those are always used as pointers. They are never defined anywhere,
 * but the libelf source code.
 */
typedef struct Elf	Elf;
typedef struct Elf_Scn	Elf_Scn;


/* archive member header */
typedef struct
{
  char		*ar_name;
  time_t	ar_date;
  long		ar_uid;
  long 		ar_gid;
  unsigned long	ar_mode;
  off_t		ar_size;
  char 		*ar_rawname;
} Elf_Arhdr;


/* archive symbol table */

typedef struct
{
  char		*as_name;
  size_t	as_off;
  unsigned long	as_hash;
} Elf_Arsym;


typedef void	Elf_Void;

/* data descriptor */
typedef struct
{
  Elf_Void	*d_buf;
  Elf_Type	d_type;
  size_t	d_size;
  off_t		d_off;		/* offset into section */
  size_t	d_align;	/* alignment in section */
  unsigned	d_version;	/* elf version */
} Elf_Data;


/*function declarations */

extern Elf *elf_begin __P((int __fds, Elf_Cmd __cmd, Elf * __ref));
extern int elf_cntl __P((Elf * ___elfds, Elf_Cmd __cmd));
extern int elf_end __P((Elf * __elfds));
extern __const char *elf_errmsg	__P((int __errno));
extern int elf_errno __P((void));
extern void elf_fill __P((int __fillchar));
extern unsigned int elf_flagdata __P((Elf_Data * __data, Elf_Cmd __cmd,
	unsigned int __flags));
extern unsigned	int elf_flagehdr __P((Elf * __elfds, Elf_Cmd __cmd,
	unsigned int __flags));
extern unsigned	int elf_flagelf __P((Elf * __elfds, Elf_Cmd __cmd,
	unsigned int __flags));
extern unsigned	int elf_flagphdr __P((Elf * __elfds, Elf_Cmd __cmd,
	unsigned int __flags));
extern unsigned	int elf_flagscn __P((Elf_Scn * __scn, Elf_Cmd __cmd,
	unsigned int __flags));
extern unsigned	int elf_flagshdr __P((Elf_Scn * __scn, Elf_Cmd __cmd,
	unsigned int __flags));
extern size_t elf32_fsize __P((Elf_Type __type, size_t __count,
	unsigned int __ver));
extern Elf_Arhdr *elf_getarhdr __P((Elf * __elfds));
extern Elf_Arsym *elf_getarsym __P((Elf * __elfds, size_t * __ptr));
extern off_t elf_getbase __P((Elf * __elfds));
extern Elf_Data *elf_getdata __P((Elf_Scn * __scn, Elf_Data * __data));
extern Elf32_Ehdr *elf32_getehdr __P((Elf * __elfds));
extern char *elf_getident __P((Elf * __elfds, size_t * __ptr));
extern Elf32_Phdr *elf32_getphdr __P((Elf *__elfds));
extern Elf_Scn *elf_getscn __P((Elf *__elfds, size_t __index));
extern Elf32_Shdr *elf32_getshdr __P((Elf_Scn * __scn));
extern unsigned long elf_hash __P((__const char * __name));
extern Elf_Kind	elf_kind __P((Elf *__elfds));
extern size_t elf_ndxscn __P((Elf_Scn *__scn));
extern Elf_Data	*elf_newdata __P((Elf_Scn * __scn));
extern Elf32_Ehdr *elf32_newehdr __P((Elf * __elfds));
extern Elf32_Phdr *elf32_newphdr __P((Elf * __elfds, size_t __count));
extern Elf_Scn *elf_newscn __P((Elf * __elfds));
extern Elf_Scn *elf_nextscn __P((Elf * __elfds, Elf_Scn * __scn));
extern Elf_Cmd elf_next __P((Elf * __elfds));
extern size_t elf_rand __P((Elf * __elfds, size_t __offset));
extern Elf_Data *elf_rawdata __P((Elf_Scn * __scn, Elf_Data * __data));
extern char *elf_rawfile __P((Elf * __elfds, size_t * __ptr));
extern char *elf_strptr __P((Elf * __elfds, size_t __section,
	size_t ___offset));
extern off_t elf_update __P((Elf * __elfds, Elf_Cmd __cmd));
extern unsigned	int elf_version __P((unsigned int __ver));
extern Elf_Data *elf32_xlatetof __P((Elf_Data * __dst,
	__const Elf_Data * __src, unsigned int __encode));
extern Elf_Data *elf32_xlatetom __P((Elf_Data * __dst,
	__const Elf_Data * __src, unsigned int __encode));

__END_DECLS

#endif	/* _LIBELF_H */
