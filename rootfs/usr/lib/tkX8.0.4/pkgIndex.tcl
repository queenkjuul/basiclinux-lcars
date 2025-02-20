# Tcl package index file, version 1.0
# 
# Package index for TkX 8.0.4.
#
if {[info tclversion] < 8.0} return
package ifneeded Tkx 8.0.4 "package require Tclx 8.0.4; package require Tk 8.0; load [list $dir/../libtkx8.0.4.so]"


