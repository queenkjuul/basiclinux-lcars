# =============================================================================
#
# File:		FileInfo.tcl
# Project:	TkDesk
#
# Started:	22.10.94
# Changed:	22.10.94
# Author:	cb
#
# Description:	Implements classes and procs for file operations like
#		copy, move, delete, file info and disk usage (and others).
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
#s    itcl_class dsk_FileInfo
#s    method config {config}
#s    method touch {}
#s    method chown {}
#s    method chgrp {}
#s    method chmod {num}
#s    proc id {}
#s    proc dsk_fileinfo {args}
#
# -----------------------------------------------------------------------------

#
# =============================================================================
#
# Class:	dsk_FileInfo
# Desc:		Implements a class for file information windows.
#
# Methods:	
# Procs:	
# Publics:
#

itcl_class dsk_FileInfo {

    constructor {args} {
	global tkdesk

	#
	# Create a toplevel with this object's name
	#
        set class [$this info class]
        ::rename $this $this-tmp-
        ::toplevel $this -class $class
	wm withdraw $this
        ::rename $this $this-top
        ::rename $this-tmp- $this

	frame $this.fl -bd 1 -relief raised
	pack $this.fl -fill x

	set f [cb_font $tkdesk(font,labels)]
	catch {set f [join [lreplace [split $f -] 7 7 18] -]}
	label $this.label -text "$file" -font [cb_font $f]
	pack $this.label -in $this.fl -side top \
		-padx $tkdesk(pad) -pady $tkdesk(pad)

	frame $this.fi -bd 1 -relief raised
	pack $this.fi -fill x

	frame $this.f1
	pack $this.f1 -in $this.fi -side left -fill x -anchor n \
		-padx $tkdesk(pad) -pady $tkdesk(pad)

	label $this.lPath -text "Path....:" -font [cb_font $tkdesk(font,mono)]
	label $this.lSize -text "Size....:" -font [cb_font $tkdesk(font,mono)]
	label $this.lLink -text "Links...:" -font [cb_font $tkdesk(font,mono)]
	label $this.lMod  -text "Modified:" -font [cb_font $tkdesk(font,mono)]
	label $this.lOwn  -text "Owner...:" -font [cb_font $tkdesk(font,mono)]
	label $this.lGrp  -text "Group...:" -font [cb_font $tkdesk(font,mono)]
	label $this.lMode -text "Mode....:" -font [cb_font $tkdesk(font,mono)]
	label $this.lType -text "Type....:" -font [cb_font $tkdesk(font,mono)]

	pack $this.lPath $this.lSize $this.lMod $this.lOwn \
		$this.lGrp $this.lMode $this.lLink $this.lType \
		-in $this.f1 -side top

	frame $this.f2
	pack $this.f2 -in $this.fi -side left -fill x \
		-padx $tkdesk(pad) -pady $tkdesk(pad)

	label $this.lrPath -text "" -font [cb_font $tkdesk(font,mono)]
	label $this.lrSize -text "" -font [cb_font $tkdesk(font,mono)]
	label $this.lrLink -text "" -font [cb_font $tkdesk(font,mono)] -height 1
	button $this.bMod -text "" -font [cb_font $tkdesk(font,mono)] \
		-command "$this touch" \
		-padx 1 -pady 1 -highlightthickness 0
	button $this.bOwn -text "" -font [cb_font $tkdesk(font,mono)] \
		-command "$this chown" \
		-padx 1 -pady 1 -highlightthickness 0
	button $this.bGrp -text "" -font [cb_font $tkdesk(font,mono)] \
		-command "$this chgrp" \
		-padx 1 -pady 1 -highlightthickness 0
	message $this.mMagic -text "" -anchor w \
		-width 200 -font [cb_font $tkdesk(font,file_lbs)] 

	frame $this.fmod
	for {set i 1} {$i < 10} {incr i} {
	    button $this.bm($i) -width 2 -font [cb_font $tkdesk(font,mono)] \
		-command "$this chmod $i" \
		-padx 1 -pady 1 -highlightthickness 0
	    # additional button bindings -- added by jdblair, 5.feb.97
	    bind $this.bm($i) <Button-1> "$this chmod $i; break"
	    bind $this.bm($i) <Button-2> "$this chmod $i Button-2"
	    bind $this.bm($i) <Button-3> "$this chmod $i Button-3"
	    pack $this.bm($i) -in $this.fmod -side left
	}

	pack $this.lrPath $this.lrSize $this.bMod $this.bOwn \
		$this.bGrp $this.fmod $this.lrLink $this.mMagic \
		-in $this.f2 -side top -anchor w

	frame $this.fa -bd 1 -relief raised
	pack $this.fa -fill both -expand yes

	frame $this.fa1
	pack $this.fa1 -in $this.fa -fill both -expand yes -pady $tkdesk(pad)

	label $this.lComment -text "Annotation:" -anchor w
	pack $this.lComment -in $this.fa1 -fill x -expand no -anchor w \
		-padx $tkdesk(pad)
	
	cb_text $this.ft -vscroll 1 -lborder 1 -pad $tkdesk(pad) \
		-width 36 -height 6 \
		-wrap word -setgrid 1
	pack $this.ft -in $this.fa1 -fill both -expand yes

	frame $this.fb -bd 1 -relief raised
	pack $this.fb -fill x

	button $this.bClose -text " Close " -command "$this close"
	button $this.bChmod -text " Change Mode " -state disabled \
		-command "$this chmod set"

	pack $this.bClose $this.bChmod -in $this.fb -side left \
		-padx $tkdesk(pad) -pady $tkdesk(pad) -ipady 1

	bind $this <Any-Enter> "focus $this.ft.text"

	wm title $this "File Information"
	wm protocol $this WM_DELETE_WINDOW "$this close"

	eval config $args
    }

    destructor {
	global tkdesk_anno
	
	set anno [string trimright [$this.ft.text get 1.0 end] \n]
	if {$anno != ""} {
	    set tkdesk_anno($file) $anno
	    dsk_refresh $file
	} elseif [info exists tkdesk_anno($file)] {
	    unset tkdesk_anno($file)
	    dsk_refresh $file
	}
	#after 10 rename $this-top {}
        catch {destroy $this}		;# destroy associated window
    }

    #
    # ----- Methods and Procs -------------------------------------------------
    #

    method close {} {
	global tkdesk_anno
	
	set anno [string trimright [$this.ft.text get 1.0 end] \n]
	if {$anno != ""} {
	    set tkdesk_anno($file) $anno
	    dsk_refresh $file
	} elseif [info exists tkdesk_anno($file)] {
	    unset tkdesk_anno($file)
	    dsk_refresh $file
	}

	wm withdraw $this
	dsk_FileInfo::cache add $this
    }

    method config {config} {
    }

    method touch {} {
	if {![file owned $file] && ![dsk_is_superuser]} {
	    dsk_errbell
	    cb_error "Sorry, you're not the owner of [file tail $file]!"
	    return
	}

	if {[cb_okcancel "Touch [file tail $file]?"] == 0} {
	    set err [catch {exec touch $file} errmsg]
	    if $err {
		cb_error $errmsg
	    } else {
		$this config -file $file
	    }
	}
    }

    method chown {} {
	global o

	if {![file owned $file] && ![dsk_is_superuser]} {
	    dsk_errbell
	    cb_error "Sorry, you're not the owner of [file tail $file]!"
	    return
	}

	set o $owner
	cb_readString "Change owner of [file tail $file] to:" o "Change Owner"
	if {$o != ""} {
	    set err [catch {exec chown $o $file} errmsg]
	    if $err {
		cb_error $errmsg
	    } else {
		$this config -file $file
	    }
	}
    }

    method chgrp {} {
	global g

	if {![file owned $file] && ![dsk_is_superuser]} {
	    dsk_errbell
	    cb_error "Sorry, you're not the owner of [file tail $file]!"
	    return
	}

	set g $group
	cb_readString "Change group of [file tail $file] to:" g "Change Group"
	if {$g != ""} {
	    set err [catch {exec chgrp $g $file} errmsg]
	    if $err {
		cb_error $errmsg
	    } else {
		$this config -file $file
	    }
	}
    }

    method chmod {num {event Button-1}} {
	# num is: user r/w/x: 1/2/3, group r/w/x: 4/5/6, world r/w/x: 7/8/9,
	# 	  or "set"
	# fmode contains the current mode string

	if {![file owned $file] && ![dsk_is_superuser]} {
	    dsk_errbell
	    cb_error "Sorry, you're not the owner of [file tail $file]!"
	    return
	}
	if [dsk_on_rofs $file] {
	    dsk_errbell
	    cb_error "Read-only file system.  Can't change permissions, sorry."
	    return
	}

	$this.bChmod config -state normal

	for {set i 0} {$i < 10} {incr i} {
	    set m($i) [string index $fmode $i]
	}

	# modified by jdblair to deal with different button events
	# button 1: normal
	# button 2: all -- set this state in all ownership classes
	# button 3: leap -- toggle execute on or off, ignoring s, S, t, T.
	if {$event == "Button-2"} {
	    switch -- $m($num) {
		"r" -
		"w" -
		"x" -
		"-" {
		    set cycle [expr $num % 3]
		    if {$cycle == 0} {set cycle 3}
		    for {set i $cycle} {$i < 10} {incr i 3} {
			set m($i) $m($num)
			$this.bm($i) config -text $m($num)
	    }
		}
	    }
	} else {
	    switch $num {
		1	-
		4	-
		7   {
		    if {$m($num) == "r"} {
			set m($num) "-"
		    } else {
			set m($num) "r"
		    }
	        }
		2	-
		5	-
		8   {
		    if {$m($num) == "w"} {
			set m($num) "-"
		    } else {
			set m($num) "w"
		    }
		}
		3	-
		6	{
		    if {$event == "Button-3"} {
			if {$m($num) == "x"} {
			    set m($num)  "-"
			} else {
			    set m($num)  "x"
			}
		    } else {
			if {$m($num) == "x"} {
			    set m($num) "s"
			} elseif {$m($num) == "s"} {
			    set m($num) "S"
			} elseif {$m($num) == "S"} {
			    set m($num) "-"
			} else {
			    set m($num)  "x"
			}
		    }
	        }
		9	{
		    if {$event == "Button-3"} {
			if {$m($num) == "x"} {
			    set m($num)  "-"
			} else {
			    set m($num)  "x"
			}
		    } else {
			if {$m($num) == "x"} {
			    set m($num) "t"
			} elseif {$m($num) == "t"} {
			    set m($num) "T"
			} elseif {$m($num) == "T"} {
			    set m($num) "-"
			} else {
			    set m($num)  "x"
			}
		    }
	        }
	    }
  	}

	if {$num != "set"} {
	    $this.bm($num) config -text $m($num)
	    set fmode ""
	    for {set i 0} {$i < 10} {incr i} {
	    	append fmode $m($i)
	    }
	} else {
	    set s 0 ; set o 0 ; set g 0 ; set w 0
	    if {$m(1) == "r"} {incr o 4}
	    if {$m(2) == "w"} {incr o 2}
	    if {$m(3) == "x"} {
		incr o 1
	    } else {
		if {$m(3) != "-"} {
		    incr s 4
		    if {$m(3) == "s"} {incr o 1}
		}
	    }
	    if {$m(4) == "r"} {incr g 4}
	    if {$m(5) == "w"} {incr g 2}
	    if {$m(6) == "x"} {
		incr g 1
	    } else {
		if {$m(6) != "-"} {
		    incr s 2
		    if {$m(6) == "s"} {incr g 1}
		}
	    }
	    if {$m(7) == "r"} {incr w 4}
	    if {$m(8) == "w"} {incr w 2}
	    if {$m(9) == "x"} {
		incr w 1
	    } else {
		if {$m(9) != "-"} {
		    incr s 1
		    if {$m(9) == "t"} {incr w 1}
		}
	    }

	    set amode ""
	    append amode $s $o $g $w
	    set err [catch {exec chmod $amode $file} errmsg]
	    if $err {
		dsk_errbell
		cb_error $errmsg
	    }
	    dsk_refresh $file
	    catch {$this.bChmod config -state disabled}
	}
    }

    proc id {} {
	set i $id
	incr id
	return $i
    }

    proc cache {cmd args} {
	switch $cmd {
	    "get" {
		if {$objectCache == {}} {
		    return [eval dsk_FileInfo .fi[dsk_FileInfo :: id] $args]
		} else {
		    #puts "objectCache before: $objectCache"
		    set obj [lindex $objectCache 0]
		    set objectCache [lrange $objectCache 1 end]
		    #puts "objectCache after:  $objectCache"
		    eval $obj config $args
		    return $obj
		}
	    }
	    "add" {
		lappend objectCache $args
	    }
	}
    }

    #
    # ----- Variables ---------------------------------------------------------
    #

    public file "" {
	global tkdesk tkdesk_anno

	if ![file exists $file] {return}
	dsk_debug "file: $file"	

	dsk_busy
	if [file isdirectory $file] {
	    set file [string trimright $file "/"]/
	    set file [dsk_canon_path $file]
	    if {$file != "/"} {
		set file [string trimright $file "/"]
	    }
	}
	set n [file tail $file]
	if {$n == ""} {set n "/"}
	$this.label config -text $n
	set p [file dirname $file]
	if {[string first $tkdesk(trashdir) $p] == 0} {
	    set p [string range $p \
		    [string length $tkdesk(trashdir)/] 1000]
	    if {$p == ""} {
		set p "Trash"
	    }
	}
	$this.lrPath config -text [cb_tilde $p collapse]
	set lsl ""
	set lsl [lindex [dskC_ls -l -o $file] 0]
	#regsub -all {\\t} $lsl "\t" lsl
	set lsl [split $lsl "\t"]
	dsk_debug "$file: $lsl"
	$this.lrSize config -text "[lindex $lsl 1] Bytes"
	$this.lrLink config -text [string trimleft [lindex $lsl 6] " "]
	$this.bMod config -text "[lindex $lsl 2]"
	set owner [lindex $lsl 3]
	$this.bOwn config -text "$owner"
	set group [lindex $lsl 4]
	$this.bGrp config -text "$group"

	set fmode [lindex $lsl 5]
	for {set i 1} {$i < 10} {incr i} {
	    $this.bm($i) config -text [string index $fmode $i]
	}

	set err [catch {set m [exec file $file]} errmsg]
	if !$err {
	    $this.mMagic config -text [string trimleft [string range $m \
		    [expr [string first ":" $m] + 1] 10000] " "]
	} else {
	    $this.mMagic config -text $errmsg
	}

	$this.ft.text delete 1.0 end
	if [info exists tkdesk_anno($file)] {
	    $this.ft.text insert end $tkdesk_anno($file)
	}

	if {[file isdirectory $file] && ![winfo exists $this.bDU]} {
	    button $this.bDU -text " Disk Usage " -command "dsk_du \"$file\""
	    pack $this.bDU -in $this.fb -side left \
			-padx $tkdesk(pad) -pady $tkdesk(pad) -ipady 2
	} else {
	    if [winfo exists $this.bDU] {
		destroy $this.bDU
	    }
	}

	wm iconname $this "Info: [file tail $file]"
	if {[wm state $this] != "normal"} {
	    dsk_place_window $this fileinfo "36x6" 1
	    wm deiconify $this
	}
	dsk_lazy
    }

    protected owner
    protected group
    protected fmode

    common id 0
    common objectCache {}
}

#
# -----------------------------------------------------------------------------
#
# Proc:		dsk_fileinfo
# Args:		none!
# Returns: 	""
# Desc:		Creates an object of class dsk_FileInfo on each selected file
#		in the calling file viewer.
# Side-FX:	
#

proc dsk_fileinfo {args} {
    global tkdesk

    set files $args
    if {$files == ""} {
    	set files [_make_fnames_safe]
    }

    if {$files == ""} {
	dsk_bell
	cb_info "Please select one or more files first."
	return
    }

    foreach file $files {
	set file [subst -nocommands -novariables $file]
	set file [dskC_striptc $file]
	if ![file exists $file] {
	    dsk_errbell
	    cb_info "[file tail $file]\nis a broken symbolic link."
	    continue
	}
	
	if {$file != ""} {
	    #dsk_FileInfo .fi[dsk_FileInfo :: id] -file $file
	    dsk_FileInfo :: cache get -file $file
	}
    }
}

