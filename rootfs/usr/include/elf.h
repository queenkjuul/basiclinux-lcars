#ifndef _ELF_H
#define _ELF_H

#include <linux/elf.h>

struct nlist
{
  char			*n_name;	/* symbol name */
  long			n_value;	/* value of symbol */
  short			n_scnum;	/* section number */
  unsigned short	n_type;		/* type and derived type */
  char			n_sclass;	/* storage class */
  char			n_numaux;	/* number of aux. entries */
};

#endif /* _ELF_H */
