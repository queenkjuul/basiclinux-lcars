# =============================================================================
#
# File:		DiskUsage.tcl
# Project:	TkDesk
#
# Started:	22.10.94
# Changed:	22.10.94
# Author:	cb
#
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
#s    itcl_class dsk_DiskUsage
#s    method config {config}
#s    method refresh {}
#s    proc id {}
#s    proc dsk_du {dir}
#
# -----------------------------------------------------------------------------

#
# =============================================================================
#
# Class:	dsk_DiskUsage
# Desc:		Creates a window for displaying the disk usage
#		of a directory.
#
# Methods:	
# Procs:	
# Publics:	directory	name of directory
#

itcl_class dsk_DiskUsage {

    constructor {args} {
	global tkdesk

	#
	# Create a toplevel with this object's name
	# (later accessible as $this-top):
	#
        set class [$this info class]
        ::rename $this $this-tmp-
        ::toplevel $this -class $class
	wm withdraw $this
        ::rename $this $this-top
        ::rename $this-tmp- $this

	frame $this.fl -bd 1 -relief raised
	pack $this.fl -fill x

	label $this.lDir -text ""
	pack $this.lDir -in $this.fl -side left \
		-padx $tkdesk(pad) -pady $tkdesk(pad)

	cb_listbox $this.flb -vscroll 1 -hscroll 1 -lborder 1 -uborder 1 \
		-width 5 -height 1 -font [cb_font $tkdesk(font,mono)] \
		-selectmode single
	$this.flb config -bd 1 -relief raised
	pack $this.flb -fill both -expand yes

	bind $this.flb.lbox <Double-1> {
	    dsk_open_dir [lindex [%W get [%W nearest %y]] 1]
	}
	bind $this.flb.lbox <3> {
	    dsk_popup {} [lindex [%W get [%W nearest %y]] 1] %X %Y
	}

	frame $this.fb -bd 1 -relief raised
	pack $this.fb -fill x

	button $this.bClose -text " Close " -command "$this delete"
	button $this.bRefresh -text " Refresh " -command "$this refresh"
	pack $this.bClose $this.bRefresh -in $this.fb -side left \
		-padx $tkdesk(pad) -pady $tkdesk(pad) -ipady 2

	wm minsize $this 40 16
	#wm geometry $this 40x15
	wm title $this "Disk Usage"
	wm protocol $this WM_DELETE_WINDOW "$this delete"

	eval config $args
    }

    destructor {
        #after 10 rename $this-top {}		;# delete this name
        catch {destroy $this}		;# destroy associated window
    }

    #
    # ----- Methods and Procs -------------------------------------------------
    #

    method config {config} {
    }

    method refresh {} {
	$this config -directory $directory
    }

    proc id {} {
	set i $id
	incr id
	return $i
    }

    #
    # ----- Variables ---------------------------------------------------------
    #

    public dir "/" {
	$this config -directory $dir
    }

    public directory "/" {
	global tkdesk
	
	#dsk_busy
	dsk_status "Determining disk usage..."

	if {$directory != "/"} {
	    set directory [string trimright $directory "/"]
	}
	$this.lDir config -text "Disk Usage of $directory:"

	# automatically read linked directories
	set err [catch {set d [file readlink $directory]}]
	if !$err {
	    set directory $d
	}

	$this.bClose config -state disabled
	$this.bRefresh config -state disabled
	set du_list \
		[dsk_bgexec "$tkdesk(cmd,du) [list $directory] | $tkdesk(cmd,sort)" \
		"Determining disk usage..."]
	$this.bClose config -state normal
	$this.bRefresh config -state normal
	if {$du_list != "break"} {
	    set du_list [split $du_list \n]
	    $this.flb.lbox delete 0 end
	    foreach d $du_list {
	    	$this.flb.lbox insert end [string trimright [format "%6s %s" \
	    	    [lindex $d 0] [cb_tilde [lrange $d 1 1000] collapse]] "\n"]
	    }
	    $this.flb.lbox config -width 40 \
		    -height [cb_min 15 [cb_max 2 [llength $du_list]]]
	    update idletasks
	    if {[wm state $this] == "withdrawn"} {
		dsk_place_window $this diskusage ""
		wm deiconify $this
	    }
	} else {
	    if {[wm state $this] == "withdrawn"} {
		after 200 $this delete
	    }
	}
	dsk_status "Ready."
	#dsk_lazy
    }

    common id 0
}

#
# -----------------------------------------------------------------------------
#
# Proc:		dsk_du
# Args:		dir	name of directory
# Returns: 	""
# Desc:		Creates an object of class dsk_DiskUsage on $dir.
# Side-FX:	
#

proc dsk_du {dir} {
    if ![file isdirectory $dir] {
	set dir [file dirname $dir]
    }

    if {$dir != ""} {
    	dsk_DiskUsage .du[dsk_DiskUsage :: id] -directory $dir
    }
}

