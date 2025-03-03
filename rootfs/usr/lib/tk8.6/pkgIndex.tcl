if {[catch {package present Tcl 8.6b1}]} { return }
package ifneeded Tk 8.6b1 [list load [file join $dir .. libtk8.6.so] Tk]
