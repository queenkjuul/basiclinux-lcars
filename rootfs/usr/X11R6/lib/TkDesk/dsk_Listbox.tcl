# =============================================================================
#
# File:		dsk_Listbox.tcl
# Project:	TkDesk
#
# Started:	07.10.94
# Changed:	09.10.94
# Author:	cb
#
# Description:	Implements a generic listbox widget, complete with scrollbar,
#		multiselection and tags.
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
#s    itcl_class dsk_Listbox
#s    method config {config} { 
#s    method textconfig {args}
#s    method sbconfig {args}
#s    method top {{line ""}}
#s    method get {{index ""}}
#s    method tag {cmd args}
#s    method select {cmd args}
#s    method _sel_entry {index}
#s    method _unsel_entry {index}
#s    method _sel_toggle {index}
#s    method _sel_toggle_all {}
#s    method _sel_first {index}
#s    method _sel_to {index {keep 0}}
#s    method _sel_get {tagname}
#s    method _sel_clear {}
#s    method _sel_drag {cmd {keep 0} {w ""} {x ""} {y ""}}
#s    method _sel_for_dd {index}
#s    method _dd_start {x y}
#s    method _dd_end {x y min}
#s    method _last_entry {index}
#s    method _yview {line}
#s    method _winunits {}
#s    method _resizeit {}
#s    method _pack_sb {{do_pack 0}}
#s    method show_hsb {show}
#s    proc autoscrollbar {{activate ""}}
#s    proc selcolor {color}
#s    proc modifier {use_old}
#
# =============================================================================

#
# =============================================================================
#
# Class:	dsk_Listbox
# Desc:		Generic listbox metawidget.
#
# Methods:	config ?options?	for options see Publics
#		textconfig ?options?	config for text widget (redundant)
#		sbconfig ?options?	config for scrollbar (redundant)
#		top ?line?		return or make line the first visible
#		get ?index?			returns the current list
#		select <list>		select all entries in <list>
#		select clear		clear selection
#		select get		return list of selected entries
#		tag <option> <args>	options are the same as for a text
#					widget, indices are listbox entries
#					(add and remove accept lists)
# Procs:	autoscrollbar ?bool?	dis-/enable automatic packing of sb
# Publics:	pad <int>		padding of the widgets (default 4)
#		list <list>		list for listbox (default {})
#		mode <single|multi>	selection mode
#		font			font for text widget
#		width			width of text widget
#		height			height of text widget
#		seltag			config of the selection tag
#		callback <proc>		<proc> will be called after double-
#					clicks. 
#					<proc> receives the following args:
#						object	name of sending obj
#						sel	selection list
#

itcl_class dsk_Listbox {

    constructor {args} {
	#
	# Create a frame with this object's name
	# (later accessible as $this-frame):
	#
        set class [$this info class]
        ::rename $this $this-tmp-
        ::frame $this -class $class -bd 1 -relief raised
        ::rename $this $this-frame
        ::rename $this-tmp- $this

        scrollbar $this.sb -relief sunken -command "$this.text yview"
        scrollbar $this.hsb -relief sunken -command "$this.text xview" \
		-orient horizontal

        text $this.text -wrap none -relief sunken -borderwidth 2 \
                -yscrollcommand "$this.sb set" -width $width -height $height \
                -cursor top_left_arrow -setgrid 1 -padx 2 \
		-highlightthickness 0 -takefocus 0 -insertwidth 0 \
		-xscrollcommand "$this.hsb set" \
		-exportselection 0 -bg $bg -fg $fg
	
	if {[winfo depth .] == 1} {
	    $this.text config -background white
	}

	eval $this.text tag config seltag $seltag_options
	eval $this.text tag config annotag $annotag_options

	frame $this.lframe -width $pad
	frame $this.rframe -width $pad
	frame $this.tframe -height $pad
	frame $this.bsframe -height $pad
	#frame $this.corner -width [expr $pad * 2 + 19]
	#frame $this.fhs

	bindtags $this.text "$this.text all"
	
        bind $this.text <1> "
	    focus [winfo toplevel $this]
	    $this select clear
	    $this select @%x,%y
	    $this _sel_first @%x,%y
	"
	bind $this.text <${mod_extend}-1> "$this _sel_to @%x,%y"
        bind $this.text <B1-Motion> "$this _sel_to @%x,%y"
	bind $this.text <B1-Leave> \
		"$this _sel_drag start \[expr %s != 256\] %W %x %y"
	bind $this.text <B1-Enter> "$this _sel_drag stop"
	bind $this.text <ButtonRelease-1> "$this _sel_drag stop"
	bind $this.text <Shift-ButtonRelease-1> "$this _sel_drag stop"
	bind $this.text <Control-ButtonRelease-1> "$this _sel_drag stop"
	set drag(afterId) {}
        bind $this.text <Double-1> "
	    set tmp_cb \[$this info public callback -value\]
	    if {\$tmp_cb != \"\"} {
		eval \$tmp_cb $this \[$this select get\]
	    }
	"
        bind $this.text <Triple-1> {break}

        bind $this.text <${mod_toggle}-1> "
	    $this _sel_toggle @%x,%y
	    $this _sel_first @%x,%y
	"

        bind $this.text <${mod_toggle}-B1-Motion> "$this _sel_to @%x,%y 1"
	# the following is hard-coded to Shift as <Control-Double-1>
	# is already used elsewhere
        bind $this.text <Shift-Double-1> "$this _sel_toggle_all"
        bind $this.text <Any-Key> {break}

	# enable (un)packing of scrollbar after resizing:
	bind $this.text <Configure> \
		"after 200 \{catch \"$this _pack_sb\"\}; break"
	set autosb 1
	
	frame $this.bframe
	pack $this.bframe -side bottom -fill x
	frame $this.corner -width [expr $pad * 2 + [$this.sb cget -width]]
	pack $this.corner -in $this.bframe -side right -fill y
	pack $this.hsb -in $this.bframe -side left \
		-padx $pad -pady $pad -fill x -expand 1
	raise $this.hsb
	raise $this.corner
	
	pack $this.tframe -side top -fill x
	pack $this.lframe -side left -fill y
	pack $this.text -side left -fill both -expand yes
	pack $this.sb -side left -padx $pad -fill y
	
	eval config $args
	update ;# idletasks
    }

    destructor {
        #after 10 "rename $this-frame {}"		;# delete this name
        catch {destroy $this}		;# destroy associated window
    }

    #
    # ----- Methods and Procs -------------------------------------------------
    #

    method config {config} { 
    }

    method textconfig {args} {
	eval $this.text config $args
    }

    method sbconfig {args} {
	eval $this.sb config $args
    }

    method top {{line ""}} {
	# this makes line $line the first visible entry in the listbox
	# or returns its index

	if {$line == ""} {
	    return [lindex [cb_old_sb_get $this.sb] 2]
	}

	if {$line >= 0 && $line < [llength $list]} {
	    $this.text yview $line
	}
    }

    method get {{index ""}} {
	if {$index == ""} {
	    return $list
	} else {
	    return [lindex $list $index]
	}
    }

    method tag {cmd args} {
	set tagname [lindex $args 0]
	set entry [lindex $args 0]
	set elist [lindex $args 1]
	set tagargs [lrange $args 1 [llength $args]]

	switch -glob -- $cmd {
	    add		{foreach e $elist {
			    $this.text tag add $tagname \
				[expr $e + 1].0 [expr $e + 2].0
			}}
	    bind	{return [eval $this.text tag bind $tagname $tagargs]}
	    conf*	{
		for {set i 0} {$i < [llength $tagargs]} {incr i 2} {
		    set err [catch {
			$this.text tag config $tagname \
				[lindex $tagargs $i] \
				[lindex $tagargs [expr $i + 1]]
		    } errmsg]
		    if $err {
			catch {puts stderr "tkdesk: $errmsg"}
		    }
		}
	    }
	    del*	{eval $this.text tag delete $tagname $tagargs}
	    lower	{eval $this.text tag lower $tagname $tagargs}
	    names	{return [$this.text tag names \
				[expr $entry + 1].0 ]
			}
	    nextrange	{error "nextrange is not implemented. Sorry."}
	    raise	{eval $this.text tag raise $tagname $tagargs}
	    ranges	{return [$this _sel_get $tagname]}
	    remove	{foreach e $elist {
			    $this.text tag remove $tagname \
				[expr $e + 1].0 [expr $e + 2].0
			}}
	}
    }

    method select {cmd {labels ""} {invert 0}} {
	set sellist ""
	switch -glob -- $cmd {
	    clear {
		$this _sel_clear
	    }
	    get	{
		return [$this _sel_get seltag]
	    }
	    getnames {
		set n ""
		foreach s [_sel_get seltag] {
		    set f [lindex [split [lindex $list $s] \t] 0]
		    lappend n [string range $f 0 [expr [string length $f] - 2]]
		}
		return $n
	    }
	    name {
		_sel_clear
		if $invert {
		    _sel_toggle_all
		}
		set fe -1
		foreach n $labels {
		    set e 0
		    foreach le $list {
			set fn [lindex [split $le \t] 0]
			if [string match ${n}? $fn] {
			    if !$invert {
				_sel_entry $e
				if {$fe == -1} {
				    set fe $e
				}
			    } else {
				_unsel_entry $e
			    }
			}
			incr e
		    }
		}
		if {$fe > -1} {
		    $this.text see [expr $fe + 1].0
		}
	    }
	    default {
		# cmd is a list of entry numbers
		set sellist $cmd
		foreach entry $sellist {
		    $this _sel_entry $entry
		}
	    }
	}
    }

    method _sel_entry {index} {
	if {[string index $index 0] == "@" || \
		[regexp {^[1-90]+\.[1-90]$} $index]} {
	    if ![_last_entry $index] {
		$this.text tag add seltag "$index linestart" \
			"$index + 1 lines linestart"
	    }
	} else {
	    if {$index >= 0 && $index < [llength $list]} {
	    	$this.text tag add seltag [expr $index + 1].0 \
			[expr $index + 2].0
	    }
	}
	set sel_select 1
    }

    method _unsel_entry {index} {
	if {[string index $index 0] == "@" || \
		[regexp {^[1-90]+\.[1-90]$} $index]} {
	    $this.text tag remove seltag "$index linestart" \
					"$index + 1 lines linestart"
	} else {
	    $this.text tag remove seltag [expr $index + 1].0 \
						[expr $index + 2].0
	}
	set sel_select 0
    }

    method _sel_toggle {index} {
	# is bound to <${mod_toggle}-1>
	if {$mode == "single"} {
	    return
	}
	
	if {[string index $index 0] != "@" && \
		![regexp {^[1-90]+\.[1-90]$} $index]} {
	    set index [expr $index + 1].0
	}

	if [_last_entry $index] return

	if {[lsearch [$this.text tag names $index] "seltag"] > -1} {
	    $this _unsel_entry $index
	    set was_selected 1
	} else {
	    $this _sel_entry $index
	    set was_selected 0
	}
    }

    method _sel_toggle_all {} {
	if {$mode != "single"} {
	    if {$was_selected} {
		$this select clear
	    } else {
		if $has_dots {
		    $this.text tag add seltag 3.0 "end - 1 lines"
		} else {
		    $this.text tag add seltag 1.0 "end - 1 lines"
		}
	    }
	}
    }

    method _sel_first {index} {
	# index has the form @%x,%y !
	# But I'm looking for the line number; that's what the hack 
	# below is for.

	if {[string index $index 0] == "@" || \
		[regexp {^[1-90]+\.[1-90]$} $index]} {
	    $this.text tag add pos \
		    "$index linestart" "$index + 1 lines linestart"
	    set sel_start [lindex [$this.text tag ranges pos] 0]
	    $this.text tag remove pos "$index linestart" \
		    "$index + 1 lines linestart"
	} else {
	    set sel_start [expr $index + 1].0
	}
	if [_last_entry $sel_start] {
	    set sel_start [$this.text index "end - 2 lines"]
	}

	if {$sel_start == ""} {
	    set sel_start [llength $list].0
	}
    }

    method _sel_to {index {keep 0}} {
	# is bound to <B1-Motion> ==> index has the form @x,y

	if {$mode == "single"} {
	    $this _sel_clear
	    $this _sel_entry $index
	} else {
	    #
	    #  @x,y ==> line.char:
	    #
	    if [_last_entry $index] return
	    if {$sel_start == ""} return
	    
	    set sel_end [$this.text index "$index linestart"]

	    if [$this.text compare $sel_start < $sel_end] {
		if {!$keep && $sel_select} {
	    	    $this.text tag remove seltag 1.0 "$sel_start"
	    	    $this.text tag remove seltag "$sel_end + 1 lines" end
		}
		if $sel_select {
	    	    $this.text tag add seltag "$sel_start" "$sel_end + 1 lines"
		} else {
	    	    $this.text tag remove seltag "$sel_start" \
					"$sel_end + 1 lines"
		}
	    } else {
		if {!$keep && $sel_select} {
	    	    $this.text tag remove seltag 1.0 "$sel_end"
	    	    $this.text tag remove seltag "$sel_start + 1 lines" end
		}
		if $sel_select {
	    	    $this.text tag add seltag "$sel_end" "$sel_start + 1 lines"
		} else {
	    	    $this.text tag remove seltag "$sel_end" \
					"$sel_start + 1 lines"
		}
	    }
	}
    }

    method _sel_get {tagname} {
	set sel ""
	set range [$this.text tag ranges $tagname]
	for {set i 0} {$i < [llength $range]} {incr i} {
	    set from [expr int([lindex $range $i]) - 1]
	    incr i
	    set to [expr int([lindex $range $i]) - 1]
	    for {set j $from} {$j < $to} {incr j} {
		lappend sel $j
	    }
	}

	return $sel
    }

    method _sel_clear {} {
	$this.text tag remove seltag 1.0 end
    }

    method _sel_drag {cmd {keep 0} {w ""} {x ""} {y ""} {dontsel 0}} {
	if {$cmd == "start"} {
	    set drag(x) $x
	    set drag(y) $y
	} elseif {$drag(afterId) == ""} {
	    return
	}

	
	if {$cmd == "start" || $cmd == "cont"} {
	    if {$drag(y) >= [winfo height $w]} {
		$w yview scroll 2 units
	    } elseif {$drag(y) < 0} {
		$w yview scroll -2 units
	    } elseif {$drag(x) >= [winfo width $w]} {
		$w xview scroll 2 units
	    } elseif {$drag(x) < 0} {
		$w xview scroll -2 units
	    } else {
		return
	    }
	    if {!$dontsel} {
		_sel_to @$drag(x),$drag(y) $keep
	    }
	    set drag(afterId) [after $sel_drag_delay \
		    $this _sel_drag cont $keep $w {} {} $dontsel] 
	} else {
	    after cancel $drag(afterId)
	    set drag(afterId) {}
	}
    }

    method _sel_for_dd {index} {
	# index has the form @x,y

	if {[string index $index 0] != "@" && \
		![regexp {^[1-90]+\.[1-90]$} $index]} {
	    set index [expr $index + 1].0
	}
	if {[lsearch [$this.text tag names $index] "seltag"] == -1} {
	    $this select clear
	    if ![_last_entry $index] {
		$this select $index
		$this _sel_first $index
	    }
	}
    }

    method _dd_start {x y} {
	global tkdesk
	
	set tkdesk(_dd_x) $x
	set tkdesk(_dd_y) $y
    }

    method _dd_end {x y min} {
	global tkdesk
	
	#puts "$x/$_dd_x, $y/$_dd_y, $min"
	if {(abs($x - $tkdesk(_dd_x)) >= $min) || \
		(abs($y - $tkdesk(_dd_y)) >= $min)} {
	    return 1
	} else {
	    return 0
	}
    }

    method _last_entry {index} {
	# tests if $index points to the last (empty) entry
	set ec [$this.text get "$index linestart" "$index + 1 lines linestart"]
	if {$ec == "\n"} {
	    return 1
	} else {
	    return 0
	}
    }

    method _yview {line} {
	set size [$this _winunits]
	if {[expr $line + $size - 1] <= [llength $list]} {
	    $this.text yview $line
	} else {
	    $this.text yview [expr [llength $list] - $size + 1]
	}
    }

    method _winunits {} {
	# try to get window size thru scrollbar:
	set window_units [lindex [cb_old_sb_get $this.sb] 1]
	if {$window_units == 0} {
	    # window's not visible yet
	    set window_units [lindex [$this.text config -height] 4]
	}
	return $window_units
    }

    method _resizeit {} {
	# try to get window size thru scrollbar:
	update idletasks
	ot_maplist [cb_old_sb_get $this.sb] tot win f l
	if {$tot > $win} {
	    return 1
	} else {
	    return 0
	}
    }

    method _pack_sb {{do_pack 0}} {
	global tkdesk
	
	if $_pack_sb_working {
	    return
	}
	set _pack_sb_working 1

	if {$do_pack || !$tkdesk(dynamic_scrollbars)} {
	    if !$sb_packed {
	    	pack forget $this.rframe
	        pack $this.sb -side left -padx $pad -fill y
		pack $this.corner -in $this.bframe -side right -fill y
		raise $this.corner
		set sb_packed 1
	    }
	    set _pack_sb_working 0
	    return
	}

	if [_resizeit] {
	    if !$sb_packed {
	    	pack forget $this.rframe
	    	pack $this.sb -side left -padx $pad -fill y
		pack $this.corner -in $this.bframe -side right -fill y
		raise $this.corner
	    	set sb_packed 1
	    }
	} elseif $sb_packed {
	    pack forget $this.sb
	    pack $this.rframe -side left -fill y
	    pack forget $this.corner
	    set sb_packed 0
	}
	set _pack_sb_working 0
    }

    method show_hsb {show} {
	global tkdesk
	
	#puts "show_hsb: $show"
	if {$show || !$tkdesk(dynamic_scrollbars)} {
	    pack forget $this.bsframe
	    pack $this.hsb -in $this.bframe -side left \
		    -padx $pad -pady $pad -fill x -expand 1
	} else {
	    pack forget $this.hsb
	    pack $this.bsframe -in $this.bframe -side left -fill x -expand 1
	}
    }

    proc autoscrollbar {{activate ""}} {
	if {$activate == ""} {
	    return $autosb
	}
	if {$activate == $autosb} {
	    return $autosb
	}

	set autosb $activate
	if $autosb {
	    # (un)packing of the sb while resizing works not too well:
	    foreach this [itcl_info objects -class dsk_Listbox] {
	    	bind $this.text <Configure> \
			"after 200 \{catch \"$this _pack_sb\"\}; break"
	    	$this _pack_sb
	    }
	} else {
	    foreach this [itcl_info objects -class dsk_Listbox] {
	        bind $this.text <Configure> {break}
		$this _pack_sb 1
	    }
	}
    }

    proc selcolor {color} {
	if {[winfo depth .] != 1} {
	    set seltag_options "-borderwidth 0 -background $color"
	} else {
	    set seltag_options "-borderwidth 0 \
			-foreground white -background black"
	}
    }

    proc modifier {use_old} {
	if $use_old {
	    set mod_toggle "Shift"
	    set mod_extend "Control"
	} else {
	    set mod_toggle "Control"
	    set mod_extend "Shift"
	}
    }

    #
    # ----- Variables ---------------------------------------------------------
    #

    public pad 4 {
	pack $this.hsb -side bottom -padx $pad -pady $pad -fill x
	if {$sb_packed} {
	    pack $this.sb -side left -padx $pad -fill y
	}
	$this.lframe config -width $pad
	$this.rframe config -width $pad
	$this.tframe config -height $pad
	if {$pad > 0} {
	    $this-frame config -bd 1
	} else {
	    $this-frame config -bd 0
	}
    }

    public list {} {

	$this.text delete 1.0 end
	foreach entry $list {
	    $this.text insert end "$entry\n"
	}

	if $autosb {
	    after 200 $this _pack_sb
	}
    }

    public listtext {} {

	# substitute \t:
	#set list [subst -nocommands -novariables $list]
	#set list [dskC_unesc $list]
	#set list [string_replace $list \\t \t]
	#puts $list\n
	
	$this.text delete 1.0 end
	$this.text insert end $listtext
    }

    public font fixed {
	$this.text config -font [cb_font $font]
    }

    public width 20 {
	$this.text config -width $width
    }

    public height 10 {
	$this.text config -height $height
    }

    public bg \#d9d9d9 {
	if {[winfo depth .] > 1} {
	    $this.text config -background $bg
	}
    }

    public fg black {
	if {[winfo depth .] > 1} {
	    $this.text config -foreground $fg
	}
    }

    public seltag {} {
	eval $this.text tag config seltag $seltag
    }

    public mode "multi"
    public callback ""
    public has_dots 0

    # this is only for internal use
    public stop_dragging 1

    protected sb_packed 1
    protected _pack_sb_working 0
    protected sel_start ""
    protected sel_select ""
    protected was_selected 0
    protected drag
    set drag(afterId) ""

    common mod_toggle
    common mod_extend

    common autosb 0
    common seltag_options {-borderwidth 0 -background white}
    common annotag_options {-underline 1}
    common sel_drag_delay 80
}


dsk_Listbox :: selcolor [cb_col $tkdesk(color,listsel)]
dsk_Listbox :: modifier $tkdesk(use_old_modifiers)
