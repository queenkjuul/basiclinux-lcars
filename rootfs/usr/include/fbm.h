/*****************************************************************
 * fbm.h: FBM Release 1.0 25-Feb-90 Michael Mauldin
 *
 * Copyright (C) 1989,1990 by Michael Mauldin.  Permission is granted
 * to use this file in whole or in part for any purpose, educational,
 * recreational or commercial, provided that this copyright notice
 * is retained unchanged.  This software is available to all free of
 * charge by anonymous FTP and in the UUNET archives.
 *
 * fbm.h: Fuzzy Bitmap Definition
 *
 * USAGE
 *	# include <fbm.h>
 *
 * EDITLOG
 *	LastEditDate = Mon Jun 25 00:03:05 1990 - Michael Mauldin
 *	LastFileName = /usr2/mlm/src/misc/fbm/fbm.h
 *
 * HISTORY
 * 25-Jun-90  Michael Mauldin (mlm@cs.cmu.edu) Carnegie Mellon
 *	Package for Release 1.0
 *
 * 07-Mar-89  Michael Mauldin (mlm) at Carnegie Mellon University
 *	Beta release (version 0.9) mlm@cs.cmu.edu.
 *
 * 20-Aug-88  Michael Mauldin (mlm) at Carnegie-Mellon University
 *	Created.
 *****************************************************************/

# define FBM_MAX_TITLE		80		/* For title and credits */

# define BLACK			0		/* For 8bit files */
# define WHITE			255		/* For 8bit files */
# define BYTE			256		/* For 8bit files */

# define BIG			1		/* msb first byte order */
# define LITTLE			0		/* lsb first byte order */

# define BYTESPERLINE		32		/* For PostScript output */

# define BLANKS		"                                             "
# define SKIPARG	while (*++(*argv)); --(*argv)
# define CLRARG		strncpy (*argv, BLANKS, strlen (*argv)); \
			while (*++(*argv)); --(*argv)

# define FMT_ATK	1	/*   Andrew toolkit raster format */
# define FMT_FACE	2	/*   Bennet Yee's 1bit Face format */
# define FMT_FBM	3	/* + Fuzzy bitmap format */
# define FMT_GIF	4	/*   Compuserve Graphics Interchange */
# define FMT_IFF	5	/*   Amiga Interchange Format File */
# define FMT_LEAF	6	/*   InterLeaf image format */
# define FMT_MCP	7	/*   Macpaint format */
# define FMT_PBM	8	/*   Poskanzer 1bit format */
# define FMT_PCX	9	/*   PCX format */
# define FMT_SUN	10	/* + Sun rasterfile */
# define FMT_TIFF	11	/*   Tagged IFF, Next, Macintosh */
# define FMT_X11	12	/*   X11 format */
# define FMT_RLE	13	/*   Utah RLE format */

# define FMTCHAR ".ABFGILMPZSTXR"

# define DEF_8BIT	FMT_FBM
# define DEF_1BIT	FMT_SUN

/* An FBM bitmap header in memory */
typedef struct fbm_hdr_struct {
	int	cols;			/* Width in pixels */
	int	rows;			/* Height in pixels */
	int	planes;			/* Depth (1 for B+W, 3 for RGB) */
	int	bits;			/* Bits per pixel */
	int	physbits;		/* Bits to store each pixel */
	int	rowlen;			/* Length of a row in bytes */
	int	plnlen;			/* Length of a plane in bytes */
	int	clrlen;			/* Length of color map */
	double	aspect;			/* ratio of Y to X of one pixel */
	char	title[FBM_MAX_TITLE];	/* Null terminated title */
	char	credits[FBM_MAX_TITLE];	/* Null terminated credits */
} FBMHDR;

# define FBM_MAGIC	"%bitmap"
# define BM_MAGIC	('!' << 8 | '!')
# define PCX_MAGIC	0xa
# define GIF_MAGIC	"GIF87a"
# define IFF_MAGIC	"FORM"
# define SUN_MAGIC	0x59a66a95

/* FBM bitmap headers in files (null terminated 12 character ascii strings) */
typedef struct fbm_filehdr_struct {
	char	magic[8];		/* 2 bytes FBM_MAGIC number */
	char	cols[8];		/* Width in pixels */
	char	rows[8];		/* Height in pixels */
	char	planes[8];		/* Depth (1 for B+W, 3 for RGB) */
	char	bits[8];		/* Bits per pixel */
	char	physbits[8];		/* Bits to store each pixel */
	char	rowlen[12];		/* Length of a row in bytes */
	char	plnlen[12];		/* Length of a plane in bytes */
	char	clrlen[12];		/* Length of colormap in bytes */
	char	aspect[12];		/* ratio of Y to X of one pixel */
	char	title[FBM_MAX_TITLE];	/* Null terminated title */
	char	credits[FBM_MAX_TITLE];	/* Null terminated credits */
} FBMFILEHDR;

/* An FBM bitmap in memory */
typedef struct fbm_struct {
	FBMHDR hdr;			/* Bitmap header */
	unsigned char *cm;		/* Pointer to colormap */
	unsigned char *bm;		/* Pointer to raw bits */
} FBM;

/* Functions */
double atof ();
char *strcpy();
char *strncpy();

long time (), get_long ();
int get_short ();

/* Macro for getting next magic char */
# define NEXTMCH(F,S,L) (((L) > 0) ? ((L)--, *(S)++) : getc (F))
