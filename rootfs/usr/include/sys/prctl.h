/*  prctl.h

    Header file for the Linux prctl(2) system call

    Copyright (C) 1997  Richard Gooch

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

    Richard Gooch may be reached by email at  rgooch@atnf.csiro.au
    The postal address is:
      Richard Gooch, c/o ATNF, P. O. Box 76, Epping, N.S.W., 2121, Australia.
*/
#ifndef _SYS_PRCTL_H
#define _SYS_PRCTL_H

#include <features.h>

#include <linux/prctl.h>  /*  The magic values come from here  */

__BEGIN_DECLS

extern int prctl __P((int option, ...));

__END_DECLS

#endif  /*_SYS_PRCTL_H*/
