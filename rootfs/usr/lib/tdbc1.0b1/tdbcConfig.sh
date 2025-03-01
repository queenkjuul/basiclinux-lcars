# tdbcConfig.sh --
#
# This shell script (for sh) is generated automatically by TDBC's configure
# script. It will create shell variables for most of the configuration options
# discovered by the configure script. This script is intended to be included
# by the configure scripts for TDBC extensions so that they don't have to
# figure this all out for themselves.
#
# The information in this file is specific to a single platform.
#
# RCS: @(#) $Id: tdbcConfig.sh.in,v 1.4 2007/10/03 12:40:05 dkf Exp $

TDBC_LIB_SPEC="-L/usr/lib/tdbc1.0b1 -ltdbc1.0b1"
TDBC_STUB_LIB_SPEC="-L/usr/lib/tdbc1.0b1 -ltdbcstub1.0b1"
TDBC_INCLUDE_SPEC="-I/usr/include"
# TDBC_PRIVATE_INCLUDE_SPEC="@TDBC_PRIVATE_INCLUDE_SPEC@"
TDBC_CFLAGS=-DUSE_TDBC_STUBS
TDBC_VERSION=1.0b1
