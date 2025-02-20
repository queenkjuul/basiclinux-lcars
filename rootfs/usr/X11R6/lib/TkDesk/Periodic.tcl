# =============================================================================
#
# File:		periodic.tcl
# Project:	TkDesk
#
# Started:	14.10.94
# Changed:	17.10.94
# Author:	cb
#
# Description:	Implements procs for opening & executing files and for popups.
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
#s    itcl_class dsk_Periodic
#s    method config {config}
#s    method execute {}
#s    method update {}
#s    proc id {}
#s    proc dsk_periodic {{cmd ""} {period 10}}
#s    proc dsk_periodic_cb {t cmd}
#
# =============================================================================
#
# =============================================================================
#
# Class:	dsk_Periodic
# Desc:		Implements a window that periodically executes a shell
#		command and collects its output in a text widget.
#
# Methods:	
# Procs:	
# Publics:
#

itcl_class dsk_Periodic {

    constructor {args} {
	global tkdesk [set this]

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

	frame $this.fe -bd 1 -relief raised
	pack $this.fe -fill x

	label $this.lCmd -text "Command:"
	entry $this.eCmd -bd 2 -relief sunken -width 10
	bind $this.eCmd <Return> "$this.bExec.button flash
				$this.bExec.button invoke"
	bind $this.eCmd <Tab> "focus $this.eSec"
    	menubutton $this.mbHist -bd 2 -relief raised \
		-bitmap @$tkdesk(library)/cb_tools/bitmaps/combo.xbm \
		-menu $this.mbHist.menu
    	menu $this.mbHist.menu \
		-postcommand "pcmd_history buildmenu $this.mbHist.menu"
	# add dummy entry to work around bug in pre Tk 4.0p2:
	$this.mbHist.menu add command -label "dummy"
	pcmd_history changed

	frame $this.fSep -width 16
	label $this.lu1 -text "Exec every"
	entry $this.eSec -bd 2 -relief sunken -width 4
	bind $this.eSec <Return> "$this.bExec.button flash
				$this.bExec.button invoke"
	bind $this.eSec <Tab> "focus $this.eCmd"
	$this.eSec insert end $period
	label $this.lu2 -text "seconds"

	pack $this.lCmd $this.eCmd $this.mbHist $this.fSep $this.lu1 \
		$this.eSec $this.lu2 \
		-in $this.fe -side left -ipady 2 \
		-padx $tkdesk(pad) -pady $tkdesk(pad)
	pack configure $this.eCmd -fill x -expand yes
	pack configure $this.mbHist  -ipadx 2 -ipady 2

	frame $this.ft -bd 1 -relief raised
	pack $this.ft -fill both -expand yes

	cb_text $this.ftext -vscroll 1 -hscroll 1 -lborder 1 -wrap none \
		-pad $tkdesk(pad) -width 20 -height 2 -state disabled
	pack $this.ftext -in $this.ft -fill both -expand yes \
		-pady $tkdesk(pad)

	frame $this.fb -bd 1 -relief raised
	pack $this.fb -fill x

	cb_button $this.bExec -text "  Exec  " -default 1 \
		-command "$this config -period \[$this.eSec get\]
				$this config -command \[$this.eCmd get\]
				focus $this
				pcmd_history add \[$this.eCmd get\]"
	cb_button $this.bClose -text "  Close  " -command "$this delete"
	pack $this.bExec $this.bClose -in $this.fb -side left \
		-padx $tkdesk(pad) -pady $tkdesk(pad)
	set [set this](dont_exec) 0
	checkbutton $this.cbExec -text "Don't execute" \
		-variable [set this](dont_exec) \
		-command "if !\[set [set this](dont_exec)\] \
		             \{$this.bExec.button invoke\}"
	pack $this.cbExec -in $this.fb -side left \
		-padx $tkdesk(pad) -pady $tkdesk(pad)

	bind $this <Any-Enter> "+focus $this"
	bind $this <Tab> "focus $this.eCmd"

    	wm minsize $this 354 124
	#wm geometry $this 592x278
	dsk_place_window $this periodic 592x278
	wm title $this "Periodic Execution"
	wm protocol $this WM_DELETE_WINDOW "$this delete"

	eval config $args
	wm deiconify $this
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

    method execute {} {
	global [set this] tkdesk
	
	if [set [set this](dont_exec)] return
	if ![winfo exists $this] return
	
	if {[grab current] == ""} {
	    dsk_busy ;# dsk_Periodic
	    set err [catch {eval blt_bgexec [set this](var) \
		    -output [set this](result) \
		    -error [set this](error) \
		    $command </dev/null &} m]
	    if $err {
		dsk_lazy
	    	set update_started 0
		dsk_errbell
		if {[string length $m] < 100} {
	    	    cb_error "Couldn't execute $command! ($m)"
		} else {
	    	    cb_error \
			"Couldn't execute $command for some strange reason..."
		}
	    	return
	    }

	    tkwait variable [set this](var)
	    set result [set [set this](result)]
	    set errout [set [set this](error)]
	    
	    set oldy [lindex [cb_old_sb_get $this.ftext.vscroll] 2]
	    $this.ftext.text config -state normal
	    $this.ftext.text delete 1.0 end
	    if {$errout == ""} {
		$this.ftext.text insert end $result
	    } else {
		$this.ftext.text insert end $errout
	    }
	    $this.ftext.text yview $oldy
	    $this.ftext.text config -state disabled
	    dsk_lazy ;# dsk_Periodic
	}
    }

    method update {} {
	$this execute

	if $period {
	    set update_started 1
	    after [expr $period * 1000] "catch \"$this update\""
	} else {
	    set update_started 0
	}
    }

    proc id {} {
	set i $id
	incr id
	return $i
    }

    #
    # ----- Variables ---------------------------------------------------------
    #

    public command "" {
	if {$command != ""} {
	    if !$update_started {
	    	$this update
	    } else {
	    	$this execute
	    }
	}
	$this.eCmd delete 0 end
	$this.eCmd insert end $command
    }

    public period 10 {
	$this.eSec delete 0 end
	$this.eSec insert end $period
    }

    protected update_started 0

    common id 0
}

#
# -----------------------------------------------------------------------------
#
# Proc:		dsk_periodic (~_cb is the callback for the history menu)
# Args:		none
# Returns: 	""
# Desc:		Creates a window for periodic execution of shell commands.
# Side-FX:	none (hopefully)
#

proc dsk_periodic {{cmd ""} {period 10}} {

    if {$cmd != ""} {
    	dsk_Periodic .pe[dsk_Periodic :: id] -command $cmd -period $period
    } else {
    	dsk_Periodic .pe[dsk_Periodic :: id] -period $period
    }
    return
}

proc dsk_periodic_cb {t cmd} {
    $t.eCmd delete 0 end
    $t.eCmd insert end $cmd
}

