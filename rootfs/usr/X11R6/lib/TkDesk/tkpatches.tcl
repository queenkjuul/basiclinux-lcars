# =============================================================================
#
# File:		tkpatches.tcl
# Project:	TkDesk
#
# Started:	01.03.96
# Changed:	08.04.96
#
# This file redefines a few (3) procs of the Tk 4.0/4.1 library, which
# caused problems in conjunction with TkDesk.
#
# -----------------------------------------------------------------------------
#
# Sections:
#s    proc tkEntryAutoScan {w}
#s    proc tkMenuButtonDown menu
#s    proc tkMenuUnpost menu
#s    proc tkMbMotion {w upDown rootx rooty}
#s    proc tkTraverseToMenu {w char}
#s    proc tkMenuFind [info args tkMenuFind] $nb
#s    proc auto_load cmd


# tkEntryAutoScan --
# This procedure is invoked when the mouse leaves an entry window
# with button 1 down.  It scrolls the window left or right,
# depending on where the mouse is, and reschedules itself as an
# "after" command so that the window continues to scroll until the
# mouse moves back into the window or the mouse button is released.
#
# Arguments:
# w -		The entry window.
#
# CB: I modified this to check if $w still exists.

if {$tcl_version < 7.5} {  # Tcl 7.5 already contains this fix.
proc tkEntryAutoScan {w} {
    global tkPriv
    set x $tkPriv(x)

    # added the following line:
    if ![winfo exists $w] return
    
    if {$x >= [winfo width $w]} {
	$w xview scroll 2 units
	tkEntryMouseSelect $w $x
    } elseif {$x < 0} {
	$w xview scroll -2 units
	tkEntryMouseSelect $w $x
    }
    set tkPriv(afterId) [after 50 tkEntryAutoScan $w]
}
}

# tkMenuButtonDown --
# Handles button presses in menus.  There are a couple of tricky things
# here:
# 1. Change the posted cascade entry (if any) to match the mouse position.
# 2. If there is a posted menubutton, must grab to the menubutton;  this
#    overrrides the implicit grab on button press, so that the menu
#    button can track mouse motions over other menubuttons and change
#    the posted menu.
# 3. If there's no posted menubutton (e.g. because we're a torn-off menu
#    or one of its descendants) must grab to the top-level menu so that
#    we can track mouse motions across the entire menu hierarchy.
#
# Arguments:
# menu -		The menu window.
#
# CB: surrounded grab commands with catch {...}
# Reason: Error: grab failed: window not viewable

proc tkMenuButtonDown menu {
    global tkPriv
    $menu postcascade active
    if {$tkPriv(postedMb) != ""} {
	catch {grab -global $tkPriv(postedMb)}
    } else {
	while {[wm overrideredirect $menu]
		&& ([winfo class [winfo parent $menu]] == "Menu")
		&& [winfo ismapped [winfo parent $menu]]} {
	    set menu [winfo parent $menu]
	}

	# Don't update grab information if the grab window isn't changing.
	# Otherwise, we'll get an error when we unpost the menus and
	# restore the grab, since the old grab window will not be viewable
	# anymore.

	# CB: make this compatible with Tk 4.0p0
	if {[lsearch [info proc] tkSaveGrabInfo] > -1} {
	    if {$menu != [grab current $menu]} {
		tkSaveGrabInfo $menu
	    }
	}

	# Must re-grab even if the grab window hasn't changed, in order
	# to release the implicit grab from the button press.

	catch {grab -global $menu}
    }
}

# tkMenuUnpost --
# This procedure unposts a given menu, plus all of its ancestors up
# to (and including) a menubutton, if any.  It also restores various
# values to what they were before the menu was posted, and releases
# a grab if there's a menubutton involved.  Special notes:
# 1. It's important to unpost all menus before releasing the grab, so
#    that any Enter-Leave events (e.g. from menu back to main
#    application) have mode NotifyGrab.
# 2. Be sure to enclose various groups of commands in "catch" so that
#    the procedure will complete even if the menubutton or the menu
#    or the grab window has been deleted.
#
# Arguments:
# menu -		Name of a menu to unpost.  Ignored if there
#			is a posted menubutton.
#
# CB: surrounded grab set commands with catch {...}
# Reason: Error: grab failed: window not viewable

proc tkMenuUnpost menu {
    global tkPriv
    set mb $tkPriv(postedMb)

    # Restore focus right away (otherwise X will take focus away when
    # the menu is unmapped and under some window managers (e.g. olvwm)
    # we'll lose the focus completely).

    catch {focus $tkPriv(focus)}
    set tkPriv(focus) ""

    # Unpost menu(s) and restore some stuff that's dependent on
    # what was posted.

    catch {
	if {$mb != ""} {
	    set menu [$mb cget -menu]
	    $menu unpost
	    set tkPriv(postedMb) {}
	    $mb configure -cursor $tkPriv(cursor)
	    $mb configure -relief $tkPriv(relief)
	} elseif {$tkPriv(popup) != ""} {
	    $tkPriv(popup) unpost
	    set tkPriv(popup) {}
	} elseif {[wm overrideredirect $menu]} {
	    # We're in a cascaded sub-menu from a torn-off menu or popup.
	    # Unpost all the menus up to the toplevel one (but not
	    # including the top-level torn-off one) and deactivate the
	    # top-level torn off menu if there is one.

	    while 1 {
		set parent [winfo parent $menu]
		if {([winfo class $parent] != "Menu")
			|| ![winfo ismapped $parent]} {
		    break
		}
		$parent activate none
		$parent postcascade none
		if {![wm overrideredirect $parent]} {
		    break
		}
		set menu $parent
	    }
	    $menu unpost
	}
    }

    # Release grab, if any, and restore the previous grab, if there
    # was one.

    if {$menu != ""} {
	set grab [grab current $menu]
	if {$grab != ""} {
	    grab release $grab
	}
    }
    # CB: make this compatible with Tk 4.0p0
    if [info exists tkPriv(oldGrab)] {
	if {$tkPriv(oldGrab) != ""} {
	    if {$tkPriv(grabStatus) == "global"} {
		catch {grab set -global $tkPriv(oldGrab)}
	    } else {
		catch {grab set $tkPriv(oldGrab)}
	    }
	    set tkPriv(oldGrab) ""
	}
    }
}

# tkMbMotion -- (4.1 version)
# This procedure handles mouse motion events inside menubuttons, and
# also outside menubuttons when a menubutton has a grab (e.g. when a
# menu selection operation is in progress).
#
# Arguments:
# w -			The name of the menubutton widget.
# upDown - 		"down" means button 1 is pressed, "up" means
#			it isn't.
# rootx, rooty -	Coordinates of mouse, in (virtual?) root window.
#
# CB: Changed so that another menu is only posted if the corresponding
#     menubutton is packed in the same widget as the active one.
#     (I really think this should be standard Tk behaviour.)

proc tkMbMotion {w upDown rootx rooty} {
    global tkPriv

    if {$tkPriv(inMenubutton) == $w} {
	return
    }
    set new [winfo containing $rootx $rooty]
    if {($new != $tkPriv(inMenubutton)) && (($new == "")
	    || ([winfo toplevel $new] == [winfo toplevel $w]))} {
	if {$tkPriv(inMenubutton) != ""} {
	    tkMbLeave $tkPriv(inMenubutton)
	}
	# CB: added the following if {} for caching
	if [info exists tkPriv(menubuttonOk,$new)] {
	    if {$upDown == "down"} {
		tkMbPost $new $rootx $rooty
	    } else {
		tkMbEnter $new
	    }
	    return
	}
	if {($new != "") && ([winfo class $new] == "Menubutton")
		&& ([$new cget -indicatoron] == 0)
		&& ([$w cget -indicatoron] == 0)} {
	    # CB: added the following 4 lines
	    array set wpi [pack info $w]
	    array set newpi [pack info $new]
	    if {$wpi(-in) == $newpi(-in)} {
		set tkPriv(menubuttonOk,$new) 1
	        if {$upDown == "down"} {
		    tkMbPost $new $rootx $rooty
		} else {
		    tkMbEnter $new
		}
	    }
	}
    }
}

# tkTraverseToMenu -
# This proc can be invoked during the window is deleted.  This fix first
# checks if the window still exists.

if ![info exists tkdesk(restarted)] {
    rename tkTraverseToMenu tkTraverseToMenu-orig

    proc tkTraverseToMenu {w char} {
	if [winfo exists $w] {
	    tkTraverseToMenu-orig $w $char
	}
    }
}

#
# Fix for Tk 4.2's "comment bug" in tkMenuFind:

if {$tk_version > 4.1} {
    if [regsub {"Frame",} [info body tkMenuFind] {"Frame" ,} nb] {
	proc tkMenuFind [info args tkMenuFind] $nb
	unset nb
    }
}

# tkRecolorTree --
# This procedure changes the colors in a window and all of its
# descendants, according to information provided by the colors
# argument. This looks at the defaults provided by the option 
# database, if it exists, and if not, then it looks at the default
# value of the widget itself.
#
# Arguments:
# w -			The name of a window.  This window and all its
#			descendants are recolored.
# colors -		The name of an array variable in the caller,
#			which contains color information.  Each element
#			is named after a widget configuration option, and
#			each value is the value for that option.
#
# CB: Picked up patch from Mikhail Teterin to check for empty list
#     values in $value.  This patch is applicable to Tk versions 4.2 and 8.0.

if {$tk_version >= 4.2} {
proc tkRecolorTree {w colors} {
    global tkPalette
    upvar $colors c
    set result {}
    foreach dbOption [array names c] {
	set option -[string tolower $dbOption]
	if {![catch {$w config $option} value]} {
	    # if the option database has a preference for this
	    # dbOption, then use it, otherwise use the defaults
	    # for the widget.
	    set defaultcolor [option get $w $dbOption widgetDefault]
	    if {[string match {} $defaultcolor]} {
		if [string match {} [set valueN [lindex $value 3]]] {
		    set valueN white
		}
		set defaultcolor [winfo rgb . $valueN]
	    } else {
		set defaultcolor [winfo rgb . $defaultcolor]
	    }
	    if [string match {} [set valueN [lindex $value 4]]] {
		set valueN white
	    }
	    set chosencolor [winfo rgb . $valueN]
	    if {[string match $defaultcolor $chosencolor]} {
		# Change the option database so that future windows will get the
		# same colors.
		
		append result ";\noption add *[winfo class $w].$dbOption $c($dbOption)"
		$w configure $option $c($dbOption)
	    }
	}
    }
    foreach child [winfo children $w] {
	append result ";\n[tkRecolorTree $child c]"
    }
    return $result
}
}

if {$tkdesk(in_development) == 2} {
proc auto_load cmd {
    global auto_index auto_oldpath auto_path env errorInfo errorCode

    if [info exists auto_index($cmd)] {
	puts "$auto_index($cmd) ..."
	puts "  ($cmd <- [info level 1])"
	puts "  [time {uplevel \#0 $auto_index($cmd)}]"
	return [expr {[info commands $cmd] != ""}]
    }
    if ![info exists auto_path] {
	return 0
    }
    if [info exists auto_oldpath] {
	if {$auto_oldpath == $auto_path} {
	    return 0
	}
    }
    set auto_oldpath $auto_path
    for {set i [expr [llength $auto_path] - 1]} {$i >= 0} {incr i -1} {
	set dir [lindex $auto_path $i]
	set f ""
	if [catch {set f [open [file join $dir tclIndex]]}] {
	    continue
	}
	set error [catch {
	    set id [gets $f]
	    if {$id == "# Tcl autoload index file, version 2.0"} {
		eval [read $f]
	    } elseif {$id == "# Tcl autoload index file: each line identifies a Tcl"} {
		while {[gets $f line] >= 0} {
		    if {([string index $line 0] == "#")
		    || ([llength $line] != 2)} {
			continue
		    }
		    set name [lindex $line 0]
		    set auto_index($name) \
			    "source [file join $dir [lindex $line 1]]"
		}
	    } else {
		error "[file join $dir tclIndex] isn't a proper Tcl index file"
	    }
	} msg]
	if {$f != ""} {
	    close $f
	}
	if $error {
	    error $msg $errorInfo $errorCode
	}
    }
    if [info exists auto_index($cmd)] {
	puts "$auto_index($cmd) ..."
	puts "  ($cmd <- [info level 1])"
	puts "  [time {uplevel \#0 $auto_index($cmd)}]"
	if {[info commands $cmd] != ""} {
	    return 1
	}
    }
    return 0
}
}