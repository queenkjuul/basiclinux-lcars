# =============================================================================
#
# File:		HistEntry.tcl
# Project:	TkDesk
#
# Started:	28.01.97
# Changed:	28.01.97
# Author:	cb
#
#
# Copyright (C) 1997  Christian Bolik
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
#s    itcl_class dsk_HistEntry
#s    method config {config}
#s    method ok_pressed {}
#s    method add_pressed {}
#s    method histmenu {}
#s    proc id {}
#
# -----------------------------------------------------------------------------

#
# =============================================================================
#
# Class:	dsk_HistEntry
# Desc:		Creates a dialog window with a text entry field plus
#               attached history.
#
# Methods:	
# Procs:	
# Publics:
#

itcl_class dsk_HistEntry {

    constructor {config} {
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

	frame $this.f -bd 1 -relief raised
	pack $this.f -fill both -expand yes

	frame $this.fl
	pack $this.fl -in $this.f -fill x

	label $this.label -text $label
	pack $this.label -in $this.fl -side left \
		-padx $tkdesk(pad) -pady $tkdesk(pad)

	set [set this](cbvar) $checkvalue
	if {$checklabel != ""} {
	    checkbutton $this.cbBrowser -text $checklabel \
		    -variable [set this](cbvar)
	    pack $this.cbBrowser -in $this.fl -side right \
		    -padx $tkdesk(pad) -pady $tkdesk(pad)
	}

	frame $this.fe
	pack $this.fe -in $this.f -fill both -expand yes

	entry $this.entry -width 40 -bd 2 -relief sunken
	if {$entrydefault != ""} {
	    $this.entry insert end $entrydefault
	    $this.entry icursor end
	    $this.entry xview end
	}
	pack $this.entry -in $this.fe -fill x -expand yes -side left \
		-padx $tkdesk(pad) -pady $tkdesk(pad) -ipady 2
	bind $this.entry <Return> \
		"$this.bOK.button flash ; $this.bOK.button invoke"
	bind $this.entry <Escape> \
		"$this.bCancel.button flash ; $this.bCancel.button invoke"
	bind $this.entry <Control-c> \
		"$this.bCancel.button flash; $this.bCancel.button invoke; break"

	cb_addShortcutBinding $this.entry $this.bOK.button "o"
	cb_addShortcutBinding $this.entry $this.bApply.button "a"
	cb_addShortcutBinding $this.entry $this.bCancel.button "c"
	
	cb_bindForCompletion $this.entry <Control-Tab>
	blt_drag&drop target $this.entry handler text \
		"dd_handle_text $this.entry 1"

	if {$history != ""} {
	    menubutton $this.mbHist -bd 2 -relief raised \
		    -bitmap @$tkdesk(library)/cb_tools/bitmaps/combo.xbm \
		    -menu $this.mbHist.menu
	    pack $this.mbHist -in $this.fe -side right \
		    -padx $tkdesk(pad) -pady $tkdesk(pad) -ipadx 2 -ipady 2

	    menu $this.mbHist.menu -postcommand "$this histmenu"
	    # add dummy entry to work around bug in pre Tk 4.0p2:
	    $this.mbHist.menu add command -label "dummy"
	    $history changed
	}

	frame $this.fb -bd 1 -relief raised
	pack $this.fb -fill x

	cb_button $this.bOK -text "   OK   " \
		-underline 3 -default 1 -command "
	    set tkdesk(geometry,hist_entry) \[wm geometry $this\]
	    set [set this](entry) \[$this.entry get\]
	    destroy $this
	    update idletasks
	    $this ok_pressed
	"

	cb_button $this.bApply -text " Apply " \
		-underline 1 -command "
	    set [set this](entry) \[$this.entry get\]
	    $this ok_pressed 0
	"

	if {$addbutton != ""} {
	    set i 0
	    while {[string index $addbutton $i] == " "} {incr i}
	    set sc [string index $addbutton $i]
	    cb_button $this.bAdd -text $addbutton \
		    -underline $i -command "
	    set tkdesk(geometry,hist_entry) \[wm geometry $this\]
	    set [set this](entry) \[$this.entry get\]
	    destroy $this
	    update idletasks
	    $this add_pressed
	    "
	    cb_addShortcutBinding $this.entry $this.bAdd.button "$sc"
	}

	cb_button $this.bCancel -text " Cancel " \
		-underline 1 -command "
	    set tkdesk(geometry,hist_entry) \[wm geometry $this\]
	    $this delete
	"

	pack $this.bOK $this.bApply -in $this.fb -side left \
		-padx $tkdesk(pad) -pady $tkdesk(pad)

	if {$addbutton != ""} {
	    pack $this.bAdd -in $this.fb -side left \
		    -padx $tkdesk(pad) -pady $tkdesk(pad)
	}
	
	pack $this.bCancel -in $this.fb -side left \
		-padx $tkdesk(pad) -pady $tkdesk(pad)

	bind $this <Any-Enter> "focus $this.entry"

	wm minsize $this 326 117
	if {$title == ""} {
	    set title $label
	}
	wm title $this $title
	wm protocol $this WM_DELETE_WINDOW "$this.bCancel.button invoke"

	if ![info exists tkdesk(geometry,hist_menu)] {
	    set tkdesk(geometry,hist_menu) ""
	}
	dsk_place_window $this hist_entry "" 0 1
	wm deiconify $this

	if !$nograb {
	    grab $this
	    set old_focus [focus]
	    focus -force $this.entry
	    tkwait window $this
	    catch {focus -force $old_focus}
	}
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

    method ok_pressed {{delete 1}} {
	global [set this]

	if {$callback != ""} {
	    eval $callback \
		    [list [set [set this](entry)]] [set [set this](cbvar)]
	}
	if $delete {
	    delete
	}
    }

    method add_pressed {} {
	global [set this]

	if {$addcallback != ""} {
	    eval $addcallback \
		    [list [set [set this](entry)]] [set [set this](cbvar)]
	}
	delete
    }

    method histmenu {} {
	global tkdesk

	catch "$this.mbHist.menu delete 0 last"
	if $tkdesk(sort_history) {
	    set l [lsort [$history get]]
	} else {
	    set l [$history get]
	}
	set ne 0
	set menu $this.mbHist.menu
	foreach ent $l {
	    $menu add command -label $ent \
		    -command "$this.entry delete 0 end ;\
		    $this.entry insert end \[list $ent\]" \
		    -font [cb_font $tkdesk(font,entries)]
	    incr ne
	    if {$ne > $tkdesk(_max_menu_entries)} {
		set om $menu
		$menu add cascade -label "More..." \
			-menu [set menu $menu.c$ne]
		catch {destroy $menu}; menu $menu; set ne 0
		foreach b [bind $om] {bind $menu $b [bind $om $b]}
	    }
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

    common id              0

    public label           "dummy"
    public title           ""
    public checklabel      ""
    public checkvalue      0
    public entrydefault    ""
    public history         ""
    public callback        ""
    public addbutton       ""
    public addcallback     ""
    public nograb          0
}

