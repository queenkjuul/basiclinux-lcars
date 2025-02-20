/*
 * Copyright (c) 1990,1991 Regents of The University of Michigan.
 * All Rights Reserved.
 *
 * Permission to use, copy, modify, and distribute this software and
 * its documentation for any purpose and without fee is hereby granted,
 * provided that the above copyright notice appears in all copies and
 * that both that copyright notice and this permission notice appear
 * in supporting documentation, and that the name of The University
 * of Michigan not be used in advertising or publicity pertaining to
 * distribution of the software without specific, written prior
 * permission. This software is supplied as is without expressed or
 * implied warranties of any kind.
 *
 *	Research Systems Unix Group
 *	The University of Michigan
 *	c/o Mike Clark
 *	535 W. William Street
 *	Ann Arbor, Michigan
 *	+1-313-763-0525
 *	netatalk@itd.umich.edu
 */

#ifndef _ATALK_AFP_H
#define _ATALK_AFP_H 1

#include <sys/types.h>
#include <netatalk/endian.h>

struct afp_status {
    u_int16_t	as_machoff;
    u_int16_t	as_versoff;
    u_int16_t	as_uamsoff;
    u_int16_t	as_iconoff;
    u_int16_t	as_flags;
};

struct afp_poststatus {
    u_int16_t   as_signoff;
    u_int16_t   as_netaddroff;
};

typedef u_int16_t AFPUserBytes;

/* protocols */
#define AFPPROTO_ASP           1
#define AFPPROTO_DSI           2

/* actual transports. the DSI ones (tcp right now) need to be
 * kept in sync w/ <atalk/dsi.h>. 
 * convention: AFPTRANS_* = (1 << DSI_*) 
 */
#define AFPTRANS_NONE          0
#define AFPTRANS_DDP          (1 << 0)
#define AFPTRANS_TCP          (1 << 1)
#define AFPTRANS_ALL          (AFPTRANS_DDP | AFPTRANS_TCP)

/* server flags */
#define AFPSRVRINFO_COPY	 (1<<0)  /* supports copyfile */
#define AFPSRVRINFO_PASSWD	 (1<<1)	 /* supports change password */
#define AFPSRVRINFO_NOSAVEPASSWD (1<<2)  /* don't allow save password */
#define AFPSRVRINFO_SRVMSGS      (1<<3)  /* supports server messages */
#define AFPSRVRINFO_SRVSIGNATURE (1<<4)  /* supports server signature */
#define AFPSRVRINFO_TCPIP        (1<<5)  /* supports tcpip */
#define AFPSRVRINFO_SRVNOTIFY    (1<<6)  /* supports server notifications */ 
#define AFPSRVRINFO_FASTBOZO	(1<<15)

#define AFP_OK		0
#define AFPERR_ACCESS	-5000
#define AFPERR_AUTHCONT	-5001
#define AFPERR_BADUAM	-5002
#define AFPERR_BADVERS	-5003
#define AFPERR_BITMAP	-5004
#define AFPERR_CANTMOVE -5005   /* can't move file */
#define AFPERR_DENYCONF	-5006
#define AFPERR_DIRNEMPT	-5007
#define AFPERR_DFULL	-5008
#define AFPERR_EOF	-5009
#define AFPERR_BUSY	-5010   /* FileBusy */
#define AFPERR_FLATVOL  -5011   /* volume doesn't support directories */
#define AFPERR_NOITEM	-5012   /* ItemNotFound */
#define AFPERR_LOCK     -5013   /* LockErr */
#define AFPERR_MISC     -5014   /* misc. err */
#define AFPERR_NLOCK    -5015   /* no more locks */
#define AFPERR_NOSRVR	-5016
#define AFPERR_EXIST	-5017
#define AFPERR_NOOBJ	-5018
#define AFPERR_PARAM	-5019
#define AFPERR_NORANGE  -5020   /* no range lock */
#define AFPERR_RANGEOVR -5021   /* range overlap */
#define AFPERR_SESSCLOS -5022   /* session closed */
#define AFPERR_NOTAUTH	-5023
#define AFPERR_NOOP	-5024
#define AFPERR_BADTYPE	-5025
#define AFPERR_NFILE	-5026
#define AFPERR_SHUTDOWN	-5027
#define AFPERR_NORENAME -5028   /* can't rename */
#define AFPERR_NODIR	-5029
#define AFPERR_ITYPE	-5030
#define AFPERR_VLOCK	-5031   /* volume locked */
#define AFPERR_OLOCK    -5032   /* object locked */
#define AFPERR_NOID     -5034   /* file thread not found */
#define AFPERR_EXISTID  -5035   /* file already has an id */
#define AFPERR_CATCHNG  -5037   /* catalog has changed */
#define AFPERR_SAMEOBJ  -5038   /* source file == destination file */
#define AFPERR_BADID    -5039   /* non-existent file id */
#define AFPERR_PWDSAME  -5040   /* same password/can't change password */
#define AFPERR_PWDSHORT -5041   /* password too short */
#define AFPERR_PWDEXPR  -5042   /* password expired */
#define AFPERR_INSRHRD  -5043   /* folder being shared is inside a
				   shared folder. may be returned by
				   afpMoveAndRename. */
#define AFPERR_INTRASH  -5044   /* shared folder in trash. */

/* AFP Attention Codes -- 4 bits */
#define AFPATTN_SHUTDOWN     (1 << 15)            /* shutdown/disconnect */
#define AFPATTN_CRASH        (1 << 14)            /* server crashed */
#define AFPATTN_MESG         (1 << 13)            /* server has message */
#define AFPATTN_NORECONNECT  (1 << 12)            /* don't reconnect */
/* server notification */
#define AFPATTN_NOTIFY       (AFPATTN_MESG | AFPATTN_NORECONNECT) 

/* extended bitmap -- 12 bits. volchanged is only useful w/ a server
 * notification, and time is only useful for shutdown. */
#define AFPATTN_VOLCHANGED   (1 << 0)             /* volume has changed */
#define AFPATTN_TIME(x)      ((x) & 0xfff)        /* time in minutes */

typedef enum {
  AFPMESG_LOGIN = 0,
  AFPMESG_SERVER = 1
} afpmessage_t;

#endif
