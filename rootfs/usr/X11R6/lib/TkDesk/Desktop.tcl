# =============================================================================
#
# File:		Desktop.tcl
# Project:	TkDesk
#
# Started:	17.12.95
# Changed:	17.09.96
# Author:	cb
#
# Description:	Manages the TkDesk "desktop", i.e. items on the root window.
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
#s    itcl_class dsk_DeskItem
#s    method config {config} {}
#s    method configure {config} {}
#s    method cget {pubvar}
#s    method drag {cmd args}
#s    method open {}
#s    method popup {x y}
#s    method _dd_pkgcmd {token}
#s    method _dd_dragcmd {}
#s    method _dd_drop {mytype}
#s    method refresh {}
#s    proc dsk_desktop_drop {x y {flb ""}}
#s    proc id {{cmd ""}}
#s    proc set_width {val}
#s    proc defimg {type img}
#s    proc move {ofile nfile}
#s    proc remove {rfile}
#
# =============================================================================

# ============================================================================
#
#   Proc    : dsk_desktop_drop
#   In      : x, y - root location
#   Out     : -
#   Desc    : Checks if a file has been dropped onto the root window (desktop).
#   Side FX : none
#
# ----------------------------------------------------------------------------

set tkdesk(drop_on_item) 0

proc dsk_desktop_drop {x y {flb ""}} {
    global tkdesk
    
    if $tkdesk(drop_on_item) {
	set tkdesk(drop_on_item) 0
	return
    }
    set w [winfo containing $x $y]
    if {$w != ""} {
	#puts $w
	set o 0
	if {[winfo class $w] != "DragDrop"} {
	    set err [catch {set o [wm overrideredirect $w]} errmsg]
	    if {($err || !$o) && ([winfo class $w] != "Icon") \
		    && ([winfo class $w] != "Menu")} {
		return 0
	    }
	    if {$o && [winfo class $w] == "dsk_DeskItem"} {
		return 0
	    }	
	    set err [catch {set o [wm state $w]} errmsg]
	    if {($err || $o == "normal") && ([winfo class $w] != "Menu")} {
		return 0
	    }
	}
    }

    # Ok, a file has been dropped outside any of TkDesk's windows -> icon
    set xoff 0
    set yoff 0
    if {$flb == ""} {
	set flist [dsk_active sel]
    } elseif {[string index $flb 0] == "."} {
	set flist [string trimright [$flb cget -directory] /]
    } else {
	set flist $flb
    }
    foreach file $flist {
	set di .di[dsk_DeskItem :: id]
	dsk_DeskItem $di -file $file -dontmap 1
	update idletasks
	set w [winfo reqwidth $di]
	set h [winfo reqheight $di]
	set x [expr [winfo pointerx $di] + $xoff]
	set y [expr [winfo pointery $di] + $yoff]
	set sw [winfo screenwidth .]
	set sh [winfo screenheight .]
	if {$x + $w > $sw} {set x [expr $sw - $w]}
	if {$y + $h > $sh} {set y [expr $sh - $h]}
	wm geometry $di +$x+$y
	wm deiconify $di
	incr xoff 16
	incr yoff 16
    }
    return 1
}


# ============================================================================
#
#   Class   : dsk_DeskItem
#   Desc    : A class for desktop items, i.e. transient windows consisting
#             of a bitmap and a label.
#   Methods : 
#   Procs   : 
#   Publics : 
#
# ----------------------------------------------------------------------------

itcl_class dsk_DeskItem {
    #inherit

    constructor {args} {
	global tkdesk

	set class [$this info class]
        ::rename $this $this-tmp-
        ::toplevel $this -class $class -bg [cb_col $tkdesk(color,icon)] \
		-cursor top_left_arrow
	wm withdraw $this
        ::rename $this $this-top
        ::rename $this-tmp- $this

	label $this.i -image [dsk_image ficons32/file.xpm] \
		-bd 0 -bg [cb_col $tkdesk(color,icon)] \
		-cursor top_left_arrow
	pack $this.i -ipadx 2 -ipady 2
	label $this.l -text "no name" -font [cb_font $tkdesk(font,file_lbs)] \
		-bd 0 -bg [cb_col $tkdesk(color,filelb)] \
		-cursor top_left_arrow -bd 1 -relief raised
	pack $this.l -ipadx 1 -ipady 1

	bind $this.i <ButtonPress-1> "$this drag start %X %Y; break"
	bind $this.i <B1-Motion> "$this drag to %X %Y; break"
	bind $this.i <Double-1> \
		"set tkdesk(file_lb,control) 0; \
		$this open; \
		break"
	bind $this.i <Control-Double-1> \
		"set tkdesk(file_lb,control) 1; \
		$this open; \
		break"
	bind $this.i <3> \
		"$this popup %X %Y ;\
		break"
	
	if {[winfo depth .] != 1} {
	    set cc [cb_col $tkdesk(color,drag)]
	} else {
	    set cc white
	}
	blt_drag&drop source $this.i config \
		-button 2 -packagecmd "$this _dd_pkgcmd" -rejectfg red \
		-selftarget 0 -send {file text} \
		-tokenanchor nw \
		-tokencursor "@$tkdesk(library)/images/xbm/hand.xbm \
			$tkdesk(library)/images/xbm/hand.mask.xbm \
			[cb_col $tkdesk(color,foreground)] $cc"

	blt_drag&drop source $this.i handler file dd_send_file \
		text dd_send_text

	if $tkdesk(desk_items,wm_managed) {
	    wm transient $this .
	    wm title $this "DeskItem"
	} else {
	    wm overrideredirect $this 1
	}
	wm geometry $this +[winfo pointerx $this]+[winfo pointery $this]

	eval config $args

	if [file isdirectory $file] {
	    blt_drag&drop target $this.i handler file "$this _dd_drop dir"
	    blt_drag&drop target $this.l handler file "$this _dd_drop dir"
	    blt_drag&drop target $this handler file "$this _dd_drop dir"
	} elseif [file_executable $file] {
	    blt_drag&drop target $this.i handler file "$this _dd_drop exec"
	    blt_drag&drop target $this.l handler file "$this _dd_drop exec"
	    blt_drag&drop target $this handler file "$this _dd_drop exec"
	}

	bind $this.i <Control-B2-Motion> \
		"set tkdesk(file_lb,control) 1;\
		[bind $this.i <B2-Motion>] ;\
		$this _dd_dragcmd"

	bind $this.i <B2-Motion> \
		"set tkdesk(file_lb,control) 0;\
		[bind $this.i <B2-Motion>] ;\
		$this _dd_dragcmd"

	# Copy bindings to other widgets of the desk item:
	# (note: "blt_drag&drop target" doesn't add bindings)
	foreach b [bind $this.i] {
	    bind $this.l $b [bind $this.i $b]
	    bind $this $b [bind $this.i $b]
	}
	
	if !$dontmap {
	    wm deiconify $this
	    tkwait visibility $this
	    catch "lower $this .dsk_welcome"
	    update
	}
    }

    destructor {
	catch {destroy $this}
    }

    
    # ---- Methods -----------------------------------------------------------

    method config {config} {}
    method configure {config} {}
    
    method cget {pubvar} {
	return [virtual set [string trimleft $pubvar -]]
    }

    method drag {cmd args} {
	global tkdesk
	
	switch $cmd {
	    "start" {
		set x [lindex $args 0]
		set y [lindex $args 1]
		set move_x [expr $x - [winfo rootx $this]]
		set move_y [expr $y - [winfo rooty $this]]
		$this.l config -cursor [$this.i cget -cursor]
		raise $this
	    }
	    "to" {
		set x [lindex $args 0]
		set y [lindex $args 1]
		wm geometry $this +[expr $x - $move_x]+[expr $y - $move_y]
	    }
	}
    }

    method open {} {
	if [file exists $file] {
	    if [file isdirectory $file] {
		dsk_open_dir $file
	    } else {
		dsk_open [dsk_active viewer] $file
	    }
	} else {
	    dsk_bell
	    if {[cb_yesno "The associated file/directory has been deleted from outside TkDesk. Remove desk item?"] == 0} {
		$this delete
	    }
	}
    }

    method popup {x y} {
	dsk_popup "" $file $x $y "deskitem $this"
    }
    
    method _dd_pkgcmd {token} {
	global tkdesk

	set tkdesk(dd_token_window) $token

	catch "destroy $token.label"	
	catch "destroy $token.lFiles"
	catch "destroy $token.lDirs"
	if $tkdesk(quick_dragndrop) {
	    set f [cb_font $tkdesk(font,labels)]
	    catch {
		set f [join [lreplace [split $f -] 7 7 10] -]
		set f [join [lreplace [split $f -] 3 3 medium] -]
	    }
	    label $token.label -text "Moving:" \
		    -font [cb_font $f]
	    pack $token.label
	}

	label $token.lFiles -text " 1 Item "
	pack $token.lFiles -anchor w

	catch "wm deiconify $token"
	focus $token
	return $file
    }

    method _dd_dragcmd {} {
	global tkdesk

	set token $tkdesk(dd_token_window)
	if $tkdesk(quick_dragndrop) {
	    if $tkdesk(file_lb,control) {
		$token.label config -text "Copying:"		
	    } else {
		$token.label config -text "Moving:"
	    }
	    update idletasks
	}
    }

    method _dd_drop {mytype} {
	global DragDrop tkdesk

	set tkdesk(drop_on_item) 1
	catch "wm withdraw $tkdesk(dd_token_window)"
	update

	if {$mytype == "dir"} {
	    if ![file writable $file] {
		dsk_errbell
	    	cb_error "You don't have write permission for this directory!"
		return
	    }
	    
	    if {[string first "$tkdesk(trashdir)/" $file] == -1} {
		dsk_ddcopy $DragDrop(file) $file
	    } else {
		if !$tkdesk(quick_dragndrop) {
		    dsk_delete $DragDrop(file)
		} else {
		    if {!$tkdesk(file_lb,control) && !$tkdesk(really_delete)} {
			dsk_ddcopy $DragDrop(file) $file
		    } else {
			if {[cb_yesno "Really deleting! Are you sure that this is what you want?"] == 0} {
			    dsk_sound dsk_really_deleting
			    dsk_bgexec "$tkdesk(cmd,rm) $DragDrop(file)" \
				    "Deleting [llength $DragDrop(file)] File(s)..."
			    dsk_refresh "$DragDrop(file) $dest"
			}
		    }		    
		}
	    }
	} elseif {$mytype == "exec"} {
	    if $tkdesk(quick_dragndrop) {
		dsk_exec $file $DragDrop(file)
	    } else {
		dsk_ask_exec "$file $DragDrop(file)"
	    }
	}
    }

    method refresh {} {
	# re-set the image:
	config -file $file
    }

    method _break_name {fname} {

	set len [string length $fname]
	if {$len <= $width} {
	    return $fname
	}

	# find a good place to insert a newline to break the filename
	set j 0
	set bname ""
	set breaki -1
	set breakc ""
	for {set i 0} {$i < $len} {incr i} {
	    set c [string index $fname $i]
	    if {[string first $c " .:_-"] > -1} {
		if {$breaki > -1} {
		    append bname [string range $fname \
			    $breaki [expr $i - 1]]
		}
		set breaki $i
		set breakc $c
	    } elseif {$breaki < 0} {
		append bname $c
	    }
	    incr j
	    
	    if {($j >= $width && $breaki >= 0) || $j > $width + 4} {
		switch -- $breakc {
		    " " {
			# replace with newline
			append bname "\n"
			append bname [string range $fname [expr $breaki +1] $i] 
		    }
		    "." {
			# insert newline before breakchar
			append bname "\n"
			append bname [string range $fname $breaki $i]
		    }
		    ":" -
		    "_" -
		    "-" {
			# insert newline after breakchar
			append bname $breakc
			append bname "\n"
			append bname [string range $fname [expr $breaki + 1] $i]
		    }
		    default {
			append bname "\n"
		    }
		}
		set breaki -1
		set breakc ""
		set j 0
	    }
	}
	if {$breaki > -1} {
	    append bname [string range $fname $breaki [expr $i - 1]]
	}
	
	return $bname
    }

    # ---- Procs -------------------------------------------------------------

    proc id {{cmd ""}} {
	if {$cmd == ""} {
	    set i $id_counter
	    incr id_counter
	    return $i
	} elseif {$cmd == "reset"} {
	    set id_counter 0
	}
    }

    proc set_width {val} {
	set width $val
    }

    proc defimg {type img} {
	set defimg_$type $img
    }

    proc move {ofile nfile} {
	# $rfile has been moved -> adjust associated icons
	foreach di [itcl_info objects -class dsk_DeskItem] {
	    if ![winfo exists $di] continue
	    set file [$di cget -file]
	    if {$file == $ofile} {
		$di config -file $nfile
	    } elseif {[string first $ofile/ $file] == 0} {
		$di config -file $nfile/[string range $file \
			[string length $nfile/] 1000]
	    }
	}
    }
    
    proc remove {rfile} {
	# $rfile has been deleted -> remove associated icons
	foreach di [itcl_info objects -class dsk_DeskItem] {
	    if ![winfo exists $di] continue
	    set file [$di cget -file]
	    if {$file == $rfile} {
		$di delete
	    } elseif {[string first $rfile/ $file] == 0} {
		$di delete
	    }
	}
    }
    

    # ---- Variables ---------------------------------------------------------

    public file "no name" {
	global tkdesk

	set havematch 0
	set fname [file tail $file]
	if [file isdirectory $file] {
	    set dicon $defimg_dir
	    if [info exists tkdesk(file_tags,directories)] {
		foreach tf $tkdesk(file_tags,directories) {
		    if {[llength $tf] > 4} {
			ot_maplist $tf pats col font licon tdicon
			foreach pat $pats {
			    if [string match $pat $fname] {
				set dicon $tdicon
				set havematch 1
				break
			    }
			}
		    }
		    if $havematch break
		}
	    }
	    $this.i config -image [dsk_image $dicon]
	} elseif [file_executable $file] {
	    set dicon $defimg_exec
	    if [info exists tkdesk(file_tags,executables)] {
		foreach tf $tkdesk(file_tags,executables) {
		    if {[llength $tf] > 4} {
			ot_maplist $tf pats col font licon tdicon
			foreach pat $pats {
			    if [string match $pat $fname] {
				set dicon $tdicon
				set havematch 1
				break
			    }
			}
		    }
		    if $havematch break
		}
	    }
	    $this.i config -image [dsk_image $dicon]
	} else {
	    set dicon $defimg_file
	    if [info exists tkdesk(file_tags)] {
		foreach tf $tkdesk(file_tags) {
		    if {[llength $tf] > 4} {
			ot_maplist $tf pats col font licon tdicon
			foreach pat $pats {
			    if [string match $pat $fname] {
				set dicon $tdicon
				set havematch 1
				break
			    }
			}
		    }
		    if $havematch break
		}
	    }
	    $this.i config -image [dsk_image $dicon]
	}
	$this.l config -text [_break_name [file tail $file]]
    }
    public dontmap 0

    protected move_x
    protected move_y

    common id_counter 0
    common width 12

    common defimg_file ficons32/file.xpm
    common defimg_dir ficons32/dir.xpm
    common defimg_exec ficons32/exec.xpm
}
