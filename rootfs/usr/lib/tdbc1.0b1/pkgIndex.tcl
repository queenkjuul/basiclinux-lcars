if {[catch {package require Tcl }]} return
package ifneeded tdbc 1.0b1  [list load [file join $dir libtdbc1.0b1.so] tdbc]
