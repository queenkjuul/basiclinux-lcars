# Tcl package index file, version 1.0
# 
# Package index for TclX 8.0.4.
#
if {[info tclversion] < 8.0} return
package ifneeded Tclx 8.0.4 "load [list $dir/../libtclx8.0.4.so]"


