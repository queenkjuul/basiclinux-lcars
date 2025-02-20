# =============================================================================
#
# File:		appbar-dialup.tcl
# Project:	TkDesk
#
# Started:	13.11.94
# Changed:	13.11.94
# Author:	cb
#
# Description:	Implements the "dial-up" application bar special.
#
# Copyright (C) 1996  Christian Bolik
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
# See the file "COPYING" in the base directory of this distribution
# for more.
#
# -----------------------------------------------------------------------------
#
# Sections:
#
# -----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# _appbar_dialup but:
# Creates a button that displays the current status of the
# dial-up link.
#

set dsk_appbar(dialup,button) ""

proc _appbar_dialup {but count} {
    global tkdesk dsk_appbar
    
    # set images to use:
    foreach img {up down} {
	set bitmap $tkdesk(appbar,dialup,$img)
	set dsk_appbar(dialup,img,$img) [dsk_image $bitmap]
    }

    # create button:
    set dsk_appbar(dialup,button) $but
    button $but -activebackground $dsk_appbar(bgcolor) \
	    -activeforeground $dsk_appbar(fgcolor) \
	    -cursor top_left_arrow \
	    -command $dsk_appbar(defaction) \
	    -padx 0 -pady 0 -highlightthickness 0 \
	    -image $dsk_appbar(dialup,img,down)

    set dsk_appbar(dialup,count) $count

    if ![info exists dsk_appbar(dialup,state)] {
	set dsk_appbar(dialup,state) down
    } else {
	# resume timer after reload
	if {$dsk_appbar(dialup,state) == "up"} {
	    set but $dsk_appbar(dialup,button)
	    $but config -image $dsk_appbar(dialup,img,up)
	    set lab $but.l
	    set dsk_appbar(dialup,label) $lab
	    label $lab -text "00:00" -font fixed -cursor top_left_arrow
	    bind $lab <ButtonPress-1> "$but config -relief sunken"
	    bind $lab <ButtonRelease-1> "$but invoke; $but config -relief raised"
	    bind $lab <3> "_appbar_show_menu $dsk_appbar(dialup,count) %X %Y"
	    bind $lab <B3-Motion> "break"
	    bindtags $lab "appbar $lab all"
	    update idletasks
	    set x 0
	    set y [expr [winfo reqheight $but] - [winfo reqheight $lab]]
	    place $lab -x $x -y $y
	    catch {after cancel $dsk_appbar(dialup,after)}
	    dsk_dialup_update
	}
    }
}


proc dsk_dialup {} {
    global tkdesk dsk_appbar

    set cmd ""
    if {$dsk_appbar(dialup,state) == "down"} {
	catch {set cmd $tkdesk(appbar,dialup,cmd_up)}
	set ns up
    } else {
	catch {set cmd $tkdesk(appbar,dialup,cmd_down)}
	set ns down
    }

    if {$cmd == ""} {
	dsk_errbell
	cb_error "Please first define tkdesk(appbar,dialup,cmd_$ns) in the AppBar config file."
	return
    }

    $dsk_appbar(dialup,button) config -image $dsk_appbar(dialup,img,$ns)
    # The following breaks because of "exec" in PPP scripts... 
    #set out [dsk_bgexec "sh -c $cmd" "Trying to connect..."]
    #if {$out != "break" && $out != "error"} {
    #	  set dsk_appbar(dialup,state) $ns
    #} else {
    #	  $dsk_appbar(dialup,button) config \
    #		  -image $dsk_appbar(dialup,img,$dsk_appbar(dialup,state))
    #}
    catch {eval exec $cmd >@stdout 2>@stderr </dev/null &}
    set dsk_appbar(dialup,state) $ns

    if {$ns == "up"} {
	set but $dsk_appbar(dialup,button)
	set lab $but.l
	set dsk_appbar(dialup,label) $lab
        label $lab -text "00:00" -font fixed -cursor top_left_arrow
	bind $lab <ButtonPress-1> "$but config -relief sunken"
	bind $lab <ButtonRelease-1> "$but invoke; $but config -relief raised"
	bind $lab <3> "_appbar_show_menu $dsk_appbar(dialup,count) %X %Y"
	bind $lab <B3-Motion> "break"
	bindtags $lab "appbar $lab all"
	update idletasks
	set x 0
	set y [expr [winfo reqheight $but] - [winfo reqheight $lab]]
	place $lab -x $x -y $y
	set dsk_appbar(dialup,secsup) 0
	set dsk_appbar(dialup,after) [after 1000 dsk_dialup_update]
    } else {
	after cancel $dsk_appbar(dialup,after)
	destroy $dsk_appbar(dialup,label)
    }
}

proc dsk_dialup_update {} {
    global dsk_appbar

    if ![winfo exists $dsk_appbar(dialup,label)] return
    
    incr dsk_appbar(dialup,secsup)
    set s [expr $dsk_appbar(dialup,secsup) % 60]
    set m [expr $dsk_appbar(dialup,secsup) / 60]
    $dsk_appbar(dialup,label) config -text [format "%02d:%02d" $m $s]
    set dsk_appbar(dialup,after) [after 1000 dsk_dialup_update]
}
