#ifndef _LINUX_GENHD_H
#define _LINUX_GENHD_H

/*
 * 	genhd.h Copyright (C) 1992 Drew Eckhardt
 *	Generic hard disk header file by  
 * 		Drew Eckhardt
 *
 *		<drew@colorado.edu>
 */

#include <linux/config.h>
#include <linux/types.h>
#include <asm/unaligned.h>

#define CONFIG_MSDOS_PARTITION 1

#ifdef __alpha__
#define CONFIG_OSF_PARTITION 1
#endif

#if defined(__sparc__) || defined(CONFIG_SMD_DISKLABEL)
#define CONFIG_SUN_PARTITION 1
#endif

#if defined(CONFIG_SGI)
#define CONFIG_SGI_PARTITION 1
#endif

/* These three have identical behaviour; use the second one if DOS fdisk gets
   confused about extended/logical partitions starting past cylinder 1023. */
#define DOS_EXTENDED_PARTITION 5
#define LINUX_EXTENDED_PARTITION 0x85
#define WIN98_EXTENDED_PARTITION 0x0f

#define LINUX_SWAP_PARTITION		0x82
#define LINUX_RAID_PARTITION		0xfd	/* autodetect RAID partition */
#define LINUX_OLD_RAID_PARTITION	0x86

#ifdef CONFIG_SOLARIS_X86_PARTITION
#define SOLARIS_X86_PARTITION	LINUX_SWAP_PARTITION
#endif

#define DM6_PARTITION		0x54	/* has DDO: use xlated geom & offset */
#define EZD_PARTITION		0x55	/* EZ-DRIVE: remap sector 1 to 0 */
#define DM6_AUX1PARTITION	0x51	/* no DDO:  use xlated geom */
#define DM6_AUX3PARTITION	0x53	/* no DDO:  use xlated geom */
	

struct partition {
	unsigned char boot_ind;		/* 0x80 - active */
	unsigned char head;		/* starting head */
	unsigned char sector;		/* starting sector */
	unsigned char cyl;		/* starting cylinder */
	unsigned char sys_ind;		/* What partition type */
	unsigned char end_head;		/* end head */
	unsigned char end_sector;	/* end sector */
	unsigned char end_cyl;		/* end cylinder */
	unsigned int start_sect;	/* starting sector counting from 0 */
	unsigned int nr_sects;		/* nr of sectors in partition */
} __attribute__((packed));

struct hd_struct {
	long start_sect;
	long nr_sects;
	int type;		/* RAID or normal */
};

/*
 * partition types Linux cares about.
 *
 * currently there are 'normal' and RAID types.
 */

static inline unsigned int ptype (unsigned char raw_type)
{
	switch (raw_type) {
		case LINUX_OLD_RAID_PARTITION:
			return LINUX_OLD_RAID_PARTITION;
		case LINUX_RAID_PARTITION:
			return LINUX_RAID_PARTITION;
		default:
	}
	return 0;
}

/*
 * the maximum length a given partition name can take (eg. "scd11")
 */
#define MAX_DISKNAME_LEN 32

struct gendisk {
	int major;			/* major number of driver */
	const char *major_name;		/* name of major driver */
	int minor_shift;		/* number of times minor is shifted to
					   get real minor */
	int max_p;			/* maximum partitions per device */
	int max_nr;			/* maximum number of real devices */

	void (*init)(struct gendisk *);	/* Initialization called before we do our thing */
	struct hd_struct *part;		/* partition table */
	int *sizes;			/* device size in blocks, copied to blk_size[] */
	int nr_real;			/* number of real devices */

	void *real_devices;		/* internal use */
	struct gendisk *next;
};

#ifdef CONFIG_SOLARIS_X86_PARTITION

#define SOLARIS_X86_NUMSLICE	8
#define SOLARIS_X86_VTOC_SANE	(0x600DDEEEUL)

struct solaris_x86_slice {
	ushort	s_tag;			/* ID tag of partition */
	ushort	s_flag;			/* permision flags */
	daddr_t s_start;		/* start sector no of partition */
	long	s_size;			/* # of blocks in partition */
};

struct solaris_x86_vtoc {
		unsigned long v_bootinfo[3];	/* info needed by mboot (unsupported) */
	unsigned long v_sanity;		/* to verify vtoc sanity */
	unsigned long v_version;	/* layout version */
	char	v_volume[8];		/* volume name */
	ushort	v_sectorsz;		/* sector size in bytes */
	ushort	v_nparts;		/* number of partitions */
	unsigned long v_reserved[10];	/* free space */
	struct solaris_x86_slice
		v_slice[SOLARIS_X86_NUMSLICE]; /* slice headers */
	time_t	timestamp[SOLARIS_X86_NUMSLICE]; /* timestamp (unsupported) */
	char	v_asciilabel[128];	/* for compatibility */
};

#endif /* CONFIG_SOLARIS_X86_PARTITION */

#ifdef CONFIG_BSD_DISKLABEL
/*
 * BSD disklabel support by Yossi Gottlieb <yogo@math.tau.ac.il>
 * updated by Marc Espie <Marc.Espie@openbsd.org>
 */
#define FREEBSD_PARTITION	0xa5    /* FreeBSD Partition ID */
#define OPENBSD_PARTITION	0xa6    /* OpenBSD Partition ID */
#define NETBSD_PARTITION	0xa9    /* NetBSD Partition ID */
#define BSDI_PARTITION		0xb7    /* BSDI Partition ID */

/* Ours is not to wonder why.. */
#define BSD_PARTITION		FREEBSD_PARTITION

/* check against BSD src/sys/sys/disklabel.h for consistency */

#define BSD_DISKMAGIC	(0x82564557UL)	/* The disk magic number */
#define BSD_MAXPARTITIONS	8
#define OPENBSD_MAXPARTITIONS	16
#define BSD_FS_UNUSED		0	/* disklabel unused partition entry ID */
struct bsd_disklabel {
	__u32	d_magic;		/* the magic number */
	__s16	d_type;			/* drive type */
	__s16	d_subtype;		/* controller/d_type specific */
	char	d_typename[16];		/* type name, e.g. "eagle" */
	char	d_packname[16];			/* pack identifier */ 
	__u32	d_secsize;		/* # of bytes per sector */
	__u32	d_nsectors;		/* # of data sectors per track */
	__u32	d_ntracks;		/* # of tracks per cylinder */
	__u32	d_ncylinders;		/* # of data cylinders per unit */
	__u32	d_secpercyl;		/* # of data sectors per cylinder */
	__u32	d_secperunit;		/* # of data sectors per unit */
	__u16	d_sparespertrack;	/* # of spare sectors per track */
	__u16	d_sparespercyl;		/* # of spare sectors per cylinder */
	__u32	d_acylinders;		/* # of alt. cylinders per unit */
	__u16	d_rpm;			/* rotational speed */
	__u16	d_interleave;		/* hardware sector interleave */
	__u16	d_trackskew;		/* sector 0 skew, per track */
	__u16	d_cylskew;		/* sector 0 skew, per cylinder */
	__u32	d_headswitch;		/* head switch time, usec */
	__u32	d_trkseek;		/* track-to-track seek, usec */
	__u32	d_flags;		/* generic flags */
#define NDDATA 5
	__u32	d_drivedata[NDDATA];	/* drive-type specific information */
#define NSPARE 5
	__u32	d_spare[NSPARE];	/* reserved for future use */
	__u32	d_magic2;		/* the magic number (again) */
	__u16	d_checksum;		/* xor of data incl. partitions */

			/* filesystem and partition information: */
	__u16	d_npartitions;		/* number of partitions in following */
	__u32	d_bbsize;		/* size of boot area at sn0, bytes */
	__u32	d_sbsize;		/* max size of fs superblock, bytes */
	struct	bsd_partition {		/* the partition table */
		__u32	p_size;		/* number of sectors in partition */
		__u32	p_offset;	/* starting sector */
		__u32	p_fsize;	/* filesystem basic fragment size */
		__u8	p_fstype;	/* filesystem type, see below */
		__u8	p_frag;		/* filesystem fragments per block */
		__u16	p_cpg;		/* filesystem cylinders per group */
	} d_partitions[BSD_MAXPARTITIONS];	/* actually may be more */
};

#endif	/* CONFIG_BSD_DISKLABEL */

#ifdef CONFIG_UNIXWARE_DISKLABEL
/*
 * Unixware slices support by Andrzej Krzysztofowicz <ankry@mif.pg.gda.pl>
 * and Krzysztof G. Baranowski <kgb@knm.org.pl>
 */

#define UNIXWARE_PARTITION     0x63		/* Partition ID, same as */
						/* GNU_HURD and SCO Unix */
#define UNIXWARE_DISKMAGIC     (0xCA5E600DUL)	/* The disk magic number */
#define UNIXWARE_DISKMAGIC2    (0x600DDEEEUL)	/* The slice table magic nr */
#define UNIXWARE_NUMSLICE      16
#define UNIXWARE_FS_UNUSED     0		/* Unused slice entry ID */

struct unixware_slice {
	__u16   s_label;	/* label */
	__u16   s_flags;	/* permission flags */
	__u32   start_sect;	/* starting sector */
	__u32   nr_sects;	/* number of sectors in slice */
};

struct unixware_disklabel {
	__u32   d_type;               	/* drive type */
	__u32   d_magic;                /* the magic number */
	__u32   d_version;              /* version number */
	char    d_serial[12];           /* serial number of the device */
	__u32   d_ncylinders;           /* # of data cylinders per device */
	__u32   d_ntracks;              /* # of tracks per cylinder */
	__u32   d_nsectors;             /* # of data sectors per track */
	__u32   d_secsize;              /* # of bytes per sector */
	__u32   d_part_start;           /* # of first sector of this partition */
	__u32   d_unknown1[12];         /* ? */
 	__u32	d_alt_tbl;              /* byte offset of alternate table */
 	__u32	d_alt_len;              /* byte length of alternate table */
 	__u32	d_phys_cyl;             /* # of physical cylinders per device */
 	__u32	d_phys_trk;             /* # of physical tracks per cylinder */
 	__u32	d_phys_sec;             /* # of physical sectors per track */
 	__u32	d_phys_bytes;           /* # of physical bytes per sector */
 	__u32	d_unknown2;             /* ? */
	__u32   d_unknown3;             /* ? */
	__u32	d_pad[8];               /* pad */

	struct unixware_vtoc {
		__u32	v_magic;		/* the magic number */
		__u32	v_version;		/* version number */
		char	v_name[8];		/* volume name */
		__u16	v_nslices;		/* # of slices */
		__u16	v_unknown1;		/* ? */
		__u32	v_reserved[10];		/* reserved */
		struct unixware_slice
			v_slice[UNIXWARE_NUMSLICE];	/* slice headers */
	} vtoc;

};  /* 408 */

#endif /* CONFIG_UNIXWARE_DISKLABEL */

extern struct gendisk *gendisk_head;	/* linked list of disks */

#ifdef CONFIG_ARCH_S390
/*
 * dasd_device_name(...)
 * formats the devicename of the indicated disk
 * into the supplied buffer, and returns a pointer
 * to that same buffer (for convenience).
 * Because the S390 DASDs span a larger namespace than other
 * platforms we need our own function.
 */
int (*genhd_dasd_name)(char*,int,int,struct gendisk*); 
#endif

/*
 * disk_name() is used by genhd.c and md.c.
 * It formats the devicename of the indicated disk
 * into the supplied buffer, and returns a pointer
 * to that same buffer (for convenience).
 */
char *disk_name (struct gendisk *hd, int minor, char *buf);

#endif
