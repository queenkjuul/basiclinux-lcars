/* -*-mode:C;tab-width:8-*-
 * gpm.h - public include file for gpm-Linux
 *
 * Copyright 1994,1995   rubini@linux.it (Alessandro Rubini)
 * Copyright (C) 1998 Ian Zimmerman <itz@rahul.net>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 ********/

#ifndef _GPM_H_
#define _GPM_H_

/* $Id: gpm.h,v 1.5 2001/04/23 09:47:00 nicos Exp $ */

#include <paths.h>              /* _PATH_VARRUN etc. */

#ifdef __cplusplus
extern "C" {
#endif

/*....................................... Xtermish stuff */

#define GPM_XTERM_ON \
  printf("%c[?1001s",27), fflush(stdout), /* save old hilit tracking */ \
  printf("%c[?1000h",27), fflush(stdout) /* enable mouse tracking */

#define GPM_XTERM_OFF \
  printf("%c[?1000l",27), fflush(stdout), /* disable mouse tracking */ \
  printf("%c[?1001r",27), fflush(stdout) /* restore old hilittracking */

/*....................................... Cfg pathnames */

/* Provide trailing slash, since mostly used for building pathnames. */

#ifndef _PATH_VARRUN
#define _PATH_VARRUN	"/var/run/"
#endif

#ifndef _PATH_DEV
#define _PATH_DEV	"/dev/"
#endif

#define GPM_NODE_DIR      _PATH_VARRUN

/* itz Wed Jul  1 11:56:46 PDT 1998 this definitely ought not to be
   world-writable; umask doesn't apply either, as gpm is most often
   run from init */

#define GPM_NODE_DIR_MODE 0775  

#define GPM_NODE_PID      GPM_NODE_DIR	"gpm.pid"
#define GPM_NODE_DEV      _PATH_DEV	"gpmctl"

/* itz Wed Jul 1 12:09:29 PDT 1998 let's simplify this by placing the
   file always in /dev whether it's a device or socket.  It doesn't
   really belong to /var/run anyway. */

#define GPM_NODE_CTL      GPM_NODE_DEV
#define GPM_NODE_FIFO     _PATH_DEV	"gpmdata"

/*....................................... Cfg buttons */

#define GPM_B_LEFT      4
#define GPM_B_MIDDLE    2
#define GPM_B_RIGHT     1

/*....................................... The event types */

enum Gpm_Etype {
  GPM_MOVE=1,
  GPM_DRAG=2,   /* exactly one of the bare ones is active at a time */
  GPM_DOWN=4,
  GPM_UP=  8,

#define GPM_BARE_EVENTS(type) ((type)&(0x0f|GPM_ENTER|GPM_LEAVE))

  GPM_SINGLE=16,            /* at most one in three is set */
  GPM_DOUBLE=32,
  GPM_TRIPLE=64,            /* WARNING: I depend on the values */

  GPM_MFLAG=128,            /* motion during click? */
  GPM_HARD=256,             /* if set in the defaultMask, force an already
                   used event to pass over to another handler */

  GPM_ENTER=512,            /* enter event, user in Roi's */
  GPM_LEAVE=1024            /* leave event, used in Roi's */
};

#define Gpm_StrictSingle(type) (((type)&GPM_SINGLE) && !((type)&GPM_MFLAG))
#define Gpm_AnySingle(type)     ((type)&GPM_SINGLE)
#define Gpm_StrictDouble(type) (((type)&GPM_DOUBLE) && !((type)&GPM_MFLAG))
#define Gpm_AnyDouble(type)     ((type)&GPM_DOUBLE)
#define Gpm_StrictTriple(type) (((type)&GPM_TRIPLE) && !((type)&GPM_MFLAG))
#define Gpm_AnyTriple(type)     ((type)&GPM_TRIPLE)

/*....................................... The event data structure */

enum Gpm_Margin {GPM_TOP=1, GPM_BOT=2, GPM_LFT=4, GPM_RGT=8};

/*....................................... The reported event */

typedef struct Gpm_Event {
  unsigned char buttons, modifiers;  /* try to be a multiple of 4 */
  unsigned short vc;
  short dx, dy, x, y;
  enum Gpm_Etype type;
  int clicks;
  enum Gpm_Margin margin;
}              Gpm_Event;

/*....................................... The handling function */

typedef int Gpm_Handler(Gpm_Event *event, void *clientdata);

/*....................................... The connection data structure */

#define GPM_MAGIC 0x47706D4C /* "GpmL" */
typedef struct Gpm_Connect {
  unsigned short eventMask, defaultMask;
  unsigned short minMod, maxMod;
  int pid;
  int vc;
}              Gpm_Connect;

/*....................................... The region of Interest */

typedef struct Gpm_Roi {
  short xMin,xMax;
  short yMin,yMax;
  unsigned short minMod, maxMod;
  unsigned short eventMask;
  unsigned short owned;
  Gpm_Handler *handler;
  void *clientdata;
  struct Gpm_Roi *prev;
  struct Gpm_Roi *next;
}              Gpm_Roi;
  

/*....................................... Global variables for the client */

extern int gpm_flag, gpm_ctlfd, gpm_fd, gpm_hflag, gpm_morekeys;

extern int gpm_zerobased;
extern int gpm_visiblepointer;
extern int gpm_mx, gpm_my; /* max x and y to fit margins */
extern struct timeval gpm_timeout;

extern unsigned char    _gpm_buf[];
extern unsigned short * _gpm_arg;

extern Gpm_Handler *gpm_handler;
extern void *gpm_data;

extern Gpm_Handler *gpm_roi_handler;
extern void *gpm_roi_data;

extern Gpm_Roi *gpm_roi;
extern Gpm_Roi *gpm_current_roi;
 

/*....................................... Prototypes for the client       */
/*                                          all of them return 0 or errno */

#include <stdio.h>      /* needed to get FILE */
#include <sys/ioctl.h>  /* to get the prototype for ioctl() */

/* liblow.c */
extern int Gpm_Open(Gpm_Connect *, int);
extern int Gpm_Close(void);
extern int Gpm_GetEvent(Gpm_Event *);
extern int Gpm_CharsQueued(void);
extern int Gpm_Getc(FILE *);
#define    Gpm_Getchar() Gpm_Getc(stdin)
extern int Gpm_Repeat(int millisec);
extern int Gpm_FitValuesM(int *x, int *y, int margin);
#define    Gpm_FitValues(x,y) Gpm_FitValuesM((x),(y),-1);
#define    Gpm_FitEvent(ePtr)   \
   do {                         \
      int _x, _y;               \
      if ((ePtr)->margin && ((ePtr)->type&(GPM_DRAG | GPM_UP)))  \
        {                       \
        _x = (ePtr)->x;         \
        _y = (ePtr)->y;         \
        Gpm_FitValuesM(&_x, &_y, (ePtr)->margin); \
        (ePtr)->x = _x;         \
        (ePtr)->y = _y;         \
	}                       \
    } while(0)                  \


/* the following is a (progn ...) form */

#define Gpm_DrawPointer(x, y, fd) \
                       (_gpm_buf[sizeof(short)-1] = 2, \
                        _gpm_arg[0] = _gpm_arg[2] = \
                                (unsigned short)(x)+gpm_zerobased, \
                        _gpm_arg[1] = _gpm_arg[3] = \
                                (unsigned short)(y)+gpm_zerobased, \
                        _gpm_arg[4] = (unsigned short)3, \
                        ioctl(fd, TIOCLINUX, _gpm_buf+sizeof(short)-1))

/* the following is a heavy thing ... */
extern int gpm_consolefd; /* liblow.c */

/* #define GPM_DRAWPOINTER(event) \
 *                      ((gpm_consolefd=open("/dev/console",O_RDWR))>=0 && \
 *                      Gpm_DrawPointer((event)->x,(event)->y,gpm_consolefd), \
 *                      close(gpm_consolefd))
 */

#define GPM_DRAWPOINTER(ePtr) \
                         (Gpm_DrawPointer((ePtr)->x,(ePtr)->y,gpm_consolefd))



/* libhigh.c */

Gpm_Handler Gpm_HandleRoi;
Gpm_Roi *Gpm_PushRoi(int x, int y, int X, int Y, int mask,
                     Gpm_Handler *fun, void *xtradata);
Gpm_Roi * Gpm_PopRoi(Gpm_Roi *which);
Gpm_Roi * Gpm_RaiseRoi(Gpm_Roi *which, Gpm_Roi *before);
Gpm_Roi * Gpm_LowerRoi(Gpm_Roi *which, Gpm_Roi *after);


/* libcurses.c */
/* #include <curses.h>  Hmm... seems risky */

extern int Gpm_Wgetch();
#define Gpm_Getch() (Gpm_Wgetch(NULL))

/* libxtra.c */
char *Gpm_GetLibVersion(int *where);
char *Gpm_GetServerVersion(int *where);
int   Gpm_GetSnapshot(Gpm_Event *ePtr);

#ifdef __cplusplus
  };
#endif


#endif /* _GPM_H_ */



