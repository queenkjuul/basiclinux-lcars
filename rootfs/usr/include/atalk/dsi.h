/*
 * Copyright (c) 1997 Adrian Sun (asun@zoology.washington.edu)
 * All rights reserved.
 */

#ifndef _DSI_H 
#define _DSI_H

#include <sys/cdefs.h>
#include <sys/types.h>
#include <sys/time.h>
#include <signal.h>

#include <netinet/in.h>
#ifdef s_net
#undef s_net /* get rid of bogus sunos definition */
#endif
#include <atalk/afp.h>
#include <atalk/server_child.h>
#include <netatalk/endian.h>

/* What a DSI packet looks like:
 0                               32
 |-------------------------------|
 |flags  |command| requestID     |
 |-------------------------------|
 |error code/enclosed data offset|
 |-------------------------------|
 |total data length              |
 |-------------------------------|
 |reserved field                 |
 |-------------------------------|

 CONVENTION: anything with a dsi_ prefix is kept in network byte order.
*/

/* these need to be kept in sync w/ AFPTRANS_* in <atalk/afp.h>. 
 * convention: AFPTRANS_* = (1 << DSI_*) */
typedef enum {
  DSI_MIN = 1,
  DSI_TCPIP = 1,
  DSI_MAX = 1
} dsi_proto;

#define DSI_BLOCKSIZ 16
struct dsi_block {
  u_int8_t dsi_flags;       /* packet type: request or reply */
  u_int8_t dsi_command;     /* command */
  u_int16_t dsi_requestID;  /* request ID */
  u_int32_t dsi_code;       /* error code or data offset */
  u_int32_t dsi_len;        /* total data length */
  u_int32_t dsi_reserved;   /* reserved field */
};

#define DSI_CMDSIZ        800
#define DSI_DATASIZ       8192
/* child and parent processes might interpret a couple of these
 * differently. */
typedef struct DSI {
  dsi_proto protocol;
  struct dsi_block header;
  struct sockaddr_in server, client;
  sigset_t sigblockset;
  struct itimerval timer, savetimer;
  u_int32_t attn_quantum;
  u_int16_t serverID, clientID;
  u_int8_t *status, commands[DSI_CMDSIZ], data[DSI_DATASIZ];
  size_t statuslen, datalen, datasize, cmdlen;
  size_t read_count, write_count;
  /* inited = initialized?, child = a child?, noreply = send reply? */
  char child, inited, noreply;
  const char *program; 
  int socket, serversock;

  /* protocol specific open/close, send/receive
   * send/receive fill in the header and use dsi->commands.
   * write/read just write/read data */
  pid_t  (*proto_open)(struct DSI *);
  void   (*proto_close)(struct DSI *);
} DSI;
  
/* DSI flags */
#define DSIFL_REQUEST    0x00
#define DSIFL_REPLY      0x01
#define DSIFL_MAX        0x01

/* DSI session options */
#define DSIOPT_SERVQUANT 0x00   /* server request quantum */
#define DSIOPT_ATTNQUANT 0x01   /* attention quantum */

/* DSI Commands */
#define DSIFUNC_CLOSE   1       /* DSICloseSession */
#define DSIFUNC_CMD     2       /* DSICommand */
#define DSIFUNC_STAT    3       /* DSIGetStatus */
#define DSIFUNC_OPEN    4       /* DSIOpenSession */
#define DSIFUNC_TICKLE  5       /* DSITickle */
#define DSIFUNC_WRITE   6       /* DSIWrite */
#define DSIFUNC_ATTN    8       /* DSIAttention */
#define DSIFUNC_MAX     8       /* largest command */

/* DSI Error codes: most of these aren't used. */
#define DSIERR_OK	0x0000
#define DSIERR_BADVERS	0xfbd6
#define DSIERR_BUFSMALL	0xfbd5
#define DSIERR_NOSESS	0xfbd4
#define DSIERR_NOSERV	0xfbd3
#define DSIERR_PARM	0xfbd2
#define DSIERR_SERVBUSY	0xfbd1
#define DSIERR_SESSCLOS	0xfbd0
#define DSIERR_SIZERR	0xfbcf
#define DSIERR_TOOMANY	0xfbce
#define DSIERR_NOACK	0xfbcd

/* server and client quanta */
#define DSI_DEFQUANT        2           /* default attention quantum size */
#define DSI_SERVQUANT       0xffffffffL /* server quantum */

/* basic initialization: dsi_init.c */
extern DSI *dsi_init __P((const dsi_proto /*protocol*/,
			  const char * /*program*/, 
			  const char * /*host*/, const char * /*address*/,
			  const int /*port*/));
extern void dsi_setstatus __P((DSI *, u_int8_t *, const size_t));

/* in dsi_getsess.c */
extern DSI *dsi_getsession __P((DSI *, server_child *, const int));
extern void dsi_kill __P((int));


/* DSI Commands: individual files */
extern void dsi_opensession __P((DSI *));
extern int  dsi_attention __P((DSI *, AFPUserBytes));
extern int  dsi_cmdreply __P((DSI *, const int));
extern void dsi_tickle __P((DSI *));
extern void dsi_getstatus __P((DSI *));
extern void dsi_close __P((DSI *));

/* low-level stream commands -- in dsi_stream.c */
extern size_t dsi_stream_write __P((DSI *, void *, const size_t));
extern size_t dsi_stream_read __P((DSI *, void *, const size_t));
extern int dsi_stream_send __P((DSI *, void *, size_t));
extern int dsi_stream_receive __P((DSI *, void *, const size_t, size_t *));

/* client writes -- dsi_write.c */
extern size_t dsi_writeinit __P((DSI *, void *, const size_t));
extern size_t dsi_write __P((DSI *, void *, const size_t));
extern void   dsi_writeflush __P((DSI *));
#define dsi_wrtreply(a,b)  dsi_cmdreply(a,b)

/* client reads -- dsi_read.c */
extern ssize_t dsi_readinit __P((DSI *, void *, const size_t, const size_t,
				 const int));
extern ssize_t dsi_read __P((DSI *, void *, const size_t));
extern void dsi_readdone __P((DSI *));

/* some useful macros */
#define dsi_serverID(x)   ((x)->serverID++)
#define dsi_send(x)       do { \
    (x)->header.dsi_len = htonl((x)->cmdlen); \
    dsi_stream_send((x), (x)->commands, (x)->cmdlen); \
} while (0)
#define dsi_receive(x)    (dsi_stream_receive((x), (x)->commands, \
					      DSI_CMDSIZ, &(x)->cmdlen))
#endif /* atalk/dsi.h */
