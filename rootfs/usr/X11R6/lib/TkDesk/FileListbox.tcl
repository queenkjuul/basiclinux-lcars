# =============================================================================
#
# File:		FileListbox.tcl
# Project:	TkDesk
#
# Started:	09.10.94
# Changed:	09.10.94
# Author:	cb
#
# Description:	Implements a class for a configurable file listbox.
#		Based on dsk_Listbox. Needs the BLT-library for drag&drop.
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
#s    itcl_class dsk_FileListbox
#s    method config {config}
#s    method cget {var}
#s    method curdir {}
#s    method refresh {}
#s    method clear {}
#s    method tagpath {{dir ""}}
#s    method imginsert {tname lines}
#s    method create_img {l image}
#s    method set_mask {m}
#s    method _ask_mask {}
#s    method command {{cmd ""}}
#s    method _build_ls_cmd {}
#s    method _selstatus {}
#s    method _dd_pkgcmd {token}
#s    method _dd_pkgcmd_mb {token}
#s    method _dd_dragcmd {}
#s    method _dd_drophandler {{win ""}}
#s    method _dragscroll {mode}
#s    method _mb_label {}
#s    method _selmask {}
#s    method _tag_icons {}
#s    proc font {fnt}
#s    proc color {col}
#s    proc defimage {img}
#s    proc pathimage {img}
#s    proc showall {val}
#s    proc longlist {val}
#s    proc topfolders {val}
#s    proc typechar {val}
#s    proc addicons {val}
#s    proc sort {val}
#s    proc tag {cmd args}
#s    proc initC {}
#s    proc print_ready {val}
#s    proc ignore {list}
#s    proc dsk_FileListbox_fileTags {}
#
# =============================================================================

#
# =============================================================================
#
# Class:	dsk_FileListbox
# Desc:		Configurable listbox widget for the displaying of file lists.
#		Consists of a menubutton on top and a dsk_Listbox.
#
# Methods:	config <options>	(see Publics below)
#		refresh			rereads the filelist
#		clear			empties the filelist
#
# Procs:	font <font>		set listbox font
#		showall <bool>		show all files ?
#		longlist <bool>		long listing ?
#		topfolders <bool>	put folders on top ?
#		typechar <bool>		append a type character ?
#		tag create <pattern> <color> ?font?
#					create a tag for files that match <p.>
#		tag config <tagname> <color> ?font?
#					configure the given tag
#
# Publics:	dir/directory		directory to display
#		mask			file mask (glob style)
#		width			width of listbox
#		height			height of listbox
#		pad			padding of listbox
#		invert <bool>		invert file lists ?
#		sort <"name"|"size"|"date"|"ext"|"not">    you know what
#		notrivialdirs <bool>	show . and .. ?
#		addsize <bool>		add size to displayed files ?
#		adddate <bool>		add date to displayed files ?
#		long <bool>		long listing ?
#

itcl_class dsk_FileListbox {

    constructor {args} {
	global [set this] tkdesk
	#
	# Create a frame with this object's name
	# (later accessible as $this-frame):
	#
        set class [$this info class]
        ::rename $this $this-tmp-
        ::frame $this -class $class
        ::rename $this $this-frame
        ::rename $this-tmp- $this

	# set config from common vars
	set showall $_showall
	set longlist $_longlist
	set topfolders $_topfolders
	set typechar $_typechar
	set add_icons $_addicons
	set sort $_sort

	frame $this.fMb
	pack $this.fMb -fill x

	menubutton $this.mb -text "" -bd 1 -relief raised \
		-menu $this.mb.menu -indicatoron 0
	cb_balloonHelp $this.mb "This is a menu button!"

	menu $this.mb.menu
	$this.mb.menu add command -label "Refresh " \
		-command "$this refresh; $this _selstatus"
	$this.mb.menu add command -label "Set Mask... " \
		-command "$this _ask_mask"
	$this.mb.menu add command -label "No Mask " \
		-command "$this no_mask"
	$this.mb.menu add separator
	$this.mb.menu add command -label "Disk Usage " \
		-command "dsk_du \[$this curdir\]"
	$this.mb.menu add command -label "Free Space " \
		-command "dsk_periodic \[list $tkdesk(cmd,df) \[$this cget -directory\]\] 60"
	$this.mb.menu add command -label "Execute here... " \
		-command "$this command"
	$this.mb.menu add command -label "Execute as root... " \
		-command "$this command {} root"
	$this.mb.menu add separator
	$this.mb.menu add checkbutton -label " Long Listing " \
		-variable [set this](longlist) \
		-command "$this config -longlist \[set [set this](longlist)\]"
	::set [set this](longlist) $longlist
	$this.mb.menu add checkbutton -label " Show All Files " \
		-variable [set this](showall) \
		-command "$this config -showall \[set [set this](showall)\]"
	::set [set this](showall) $showall
	$this.mb.menu add checkbutton -label " Inverse Order " \
		-variable [set this](invert) \
		-command "$this config -invert \[set [set this](invert)\]"
	::set [set this](invert) $invert
	$this.mb.menu add cascade -label "Sort by ... " -menu $this.mb.menu.smenu
	$this.mb.menu add separator
	$this.mb.menu add command -label "Open List Window" \
		-command "dsk_FileList .dfl\[dsk_FileList :: id\] \
			-directory \[$this info public directory -value\]"
	
	menu $this.mb.menu.smenu
	$this.mb.menu.smenu add radiobutton -label " Name " \
		-variable [set this](sort) -value name \
		-command "$this config -sort \[set [set this](sort)\]"
	$this.mb.menu.smenu add radiobutton -label " Name (fold)" \
		-variable [set this](sort) -value fold \
		-command "$this config -sort \[set [set this](sort)\]"
	$this.mb.menu.smenu add radiobutton -label " Size " \
		-variable [set this](sort) -value size \
		-command "$this config -sort \[set [set this](sort)\]"
	$this.mb.menu.smenu add radiobutton -label " Date " \
		-variable [set this](sort) -value date \
		-command "$this config -sort \[set [set this](sort)\]"
	$this.mb.menu.smenu add radiobutton -label " Extension " \
		-variable [set this](sort) -value ext \
		-command "$this config -sort \[set [set this](sort)\]"
	$this.mb.menu.smenu add radiobutton -label " Don't sort " \
		-variable [set this](sort) -value not \
		-command "$this config -sort \[set [set this](sort)\]"
	::set [set this](sort) $sort

	pack $this.mb -in $this.fMb -fill x -side left -expand no

	label $this.lFiles -text " 1234 Items" -anchor e \
		-font [cb_font $tkdesk(font,status)] -bd 3
	pack $this.lFiles -in $this.fMb -side left -padx $pad

	dsk_Listbox $this.dlb -width $width -height $height \
		-font [cb_font $lbfont] -has_dots 1 \
		-bg [cb_col $tkdesk(color,filelb)] -fg $lbcolor
	#$this.dlb.text config -tabs {190 right 205 left 300 left \
	#	 360 left 420 left 500 left 520 left}
	$this.dlb.text config -tabs {190 right 220 left 330 left \
		 390 left 450 left 540 left 560 left}
	
	if {[winfo depth .] != 1} {
	    foreach t $taglist {
	    	$this.dlb tag config $t \
			-foreground $tags($t,color) -font $tags($t,font)
	    }
	} else {
	    foreach t $taglist {
	    	$this.dlb tag config $t -font $tags($t,font)
	    }
	}

	$this.dlb tag config path -borderwidth 1 -relief raised
	# $this.dlb tag config path -underline 1
	$this.dlb tag lower path
	pack $this.dlb -fill both -expand yes

	bind $this.dlb.text <1> "+$this _tag_icons"
	bind $this.dlb.text <Shift-1> "+$this _tag_icons"

	bind $this.dlb.text <Any-Enter> {
	    if $tkdesk(focus_follows_mouse) {
		focus [winfo toplevel %W]
	    }
	}

	::set tkdesk(_doubleclick) 0
	bind $this.dlb.text <Double-1> "
	    set tkdesk(file_lb,control) 0
	    set tmpsc \$tkdesk(single_click)
	    set tkdesk(single_click) 0
	    set tkdesk(config_nostat) 1
	    set tkdesk(_doubleclick) 1
	    [winfo toplevel $this] _dblclick $this \[$this.dlb select get\]
	    set tkdesk(config_nostat) 0
	    catch {set tkdesk(single_click) \$tmpsc}
	    catch {unset tmpsc}
	    break
	"
	bind $this.dlb.text <ButtonRelease-1> \
	    "+if \$tkdesk(single_click) \{
	     set tkdesk(file_lb,control) 0
	     [winfo toplevel $this] _dblclick $this \[$this.dlb select get\]
	     \}
	     if !\$tkdesk(_doubleclick) \{
		 after 100 \{$this _quick_load \[$this.dlb select get\]
		 $this _quick_info \[$this.dlb select get\]\}
	     \} else \{
	         set tkdesk(_doubleclick) 0
	     \}
	"
	bind $this.dlb.text <Control-ButtonRelease-1> \
	    "+if \$tkdesk(single_click) \{
	     set tkdesk(file_lb,control) 1
	     [winfo toplevel $this] _dblclick $this \[$this.dlb select get\]
	    \}
	    $this _tag_icons
	    $this _selstatus
	"
	bind $this.dlb.text <Shift-ButtonRelease-1> "
	    $this _tag_icons
	    $this _selstatus
	"
	bind $this.dlb.text <Control-Double-1> "
	    $this.dlb select clear
	    $this.dlb select @%x,%y
	    $this.dlb _sel_first @%x,%y
	    set tkdesk(file_lb,control) 1
	    set tmpsc \$tkdesk(single_click)
	    set tkdesk(single_click) 0
	    set tkdesk(config_nostat) 1
	    [winfo toplevel $this] _dblclick $this \[$this.dlb select get\]
	    set tkdesk(config_nostat) 0
	    catch {set tkdesk(single_click) \$tmpsc}
	    catch {unset tmpsc}
	    break
	"

	bind $this.dlb.text <Control-Shift-1> "
	    [bind $this.dlb.text <1>]
	    $this _selmask
	"

	bind $this.dlb.text <3> "
	    [bind $this.dlb.text <1>]
	    update idletasks
	    $this _selstatus
	    [winfo toplevel $this] _popup $this \[$this.dlb select get\] %X %Y"
	bind $this.dlb.text <Control-3> {# nothing}

	bind $this.dlb.text <ButtonRelease-1> "+$this _tag_icons
	    $this _selstatus"

	if {[winfo depth .] != 1} {
	    set cc [cb_col $tkdesk(color,drag)]
	} else {
	    set cc white
	}

	blt_drag&drop source $this.dlb.text config \
		-button 2 -packagecmd "$this _dd_pkgcmd" -rejectfg red \
		-selftarget 1 -send {file text} \
		-tokenanchor nw \
		-tokencursor "@$tkdesk(library)/images/xbm/hand.xbm \
			$tkdesk(library)/images/xbm/hand.mask.xbm \
			[cb_col $tkdesk(color,foreground)] $cc"

	blt_drag&drop source $this.mb config \
		-button 2 -packagecmd "$this _dd_pkgcmd_mb" -rejectfg red \
		-selftarget 1 -send {file text} \
		-tokenanchor nw \
		-tokencursor "@$tkdesk(library)/images/xbm/hand.xbm \
			$tkdesk(library)/images/xbm/hand.mask.xbm \
			[cb_col $tkdesk(color,foreground)] $cc"

	blt_drag&drop source $this.dlb.text handler \
		file dd_send_file text dd_send_text

	blt_drag&drop source $this.mb handler \
		file dd_send_file text dd_send_text

	blt_drag&drop target $this.dlb.text handler \
		file "$this _dd_drophandler"

	blt_drag&drop target $this.mb handler \
		file "$this _dd_drophandler $this.mb"

	#bind $this.dlb.text <Shift-Button-2> "[bind Text <Button-2>]"
	#bind $this.dlb.text <Shift-B2-Motion> "[bind Text <B2-Motion>]"

	bind $this.dlb.text <ButtonPress-2> "
	    $this.dlb _sel_for_dd @%x,%y
	    $this.dlb _dd_start %X %Y
	    $this _tag_icons
	    $this _selstatus
 	    blt_drag&drop source %W config -send {file text}
	    [bind $this.dlb.text <ButtonPress-2>]
	    focus %W
	"
	bind $this.mb <ButtonPress-2> "
	    [bind $this.mb <ButtonPress-2>]
	    focus $this.dlb.text
	"

	bind $this.dlb.text <Control-ButtonPress-2> "
	    blt_drag&drop source %W config -send {file text}
	    [bind $this.dlb.text <ButtonPress-2>]
	"
		
	bind $this.dlb.text <Control-B2-Motion> \
		"set tkdesk(file_lb,control) 1 ;\
		[bind $this.dlb.text <B2-Motion>] ;\
		$this _dd_dragcmd"
		
	bind $this.dlb.text <Control-ButtonRelease-2> \
		"set tkdesk(file_lb,control) 1 ;\
		[bind $this.dlb.text <ButtonRelease-2>] ;\
	        blt_drag&drop source %W config -send {} ;\
		dsk_desktop_drop %X %Y ;\
		focus -force ."

	bind $this.dlb.text <ButtonRelease-2> \
		"set tkdesk(file_lb,control) 0 ;\
		[bind $this.dlb.text <ButtonRelease-2>] ;\
	        blt_drag&drop source %W config -send {} ;\
		dsk_desktop_drop %X %Y ;\
		focus -force ."

	bind $this.mb <Control-ButtonRelease-2> \
		"set tkdesk(file_lb,control) 1 ;\
		[bind $this.mb <ButtonRelease-2>] ;\
		dsk_desktop_drop %X %Y $this ;\
		focus -force ."

	bind $this.mb <ButtonRelease-2> \
		"set tkdesk(file_lb,control) 0 ;\
		[bind $this.mb <ButtonRelease-2>] ;\
		dsk_desktop_drop %X %Y $this ;\
		focus -force ."

	bind $this.dlb.text <B2-Motion> \
		"set tkdesk(file_lb,control) 0;\
		[bind $this.dlb.text <B2-Motion>] ;\
		$this _dd_dragcmd"

	bind $this.mb <Control-B2-Motion> \
		"set tkdesk(file_lb,control) 1 ;\
		[bind $this.mb <B2-Motion>] ;\
		$this _dd_dragcmd"
		
	bind $this.mb <B2-Motion> \
		"set tkdesk(file_lb,control) 0;\
		[bind $this.mb <B2-Motion>] ;\
		$this _dd_dragcmd"

	bind $this.dlb.text <B2-KeyRelease-Control_L> \
		"set tkdesk(file_lb,control) 0; \
		$this _dd_dragcmd"
		
	bind $this.dlb.text <B2-KeyPress-Control_L> \
		"set tkdesk(file_lb,control) 1; \
		$this _dd_dragcmd"

	# define binding tag for the list icons:
	bind listimg-$this <1> "
	    [winfo toplevel $this] _selecting $this
	    focus [winfo toplevel $this]
	    $this.dlb select clear
	    $this.dlb select \[lindex \[split %W :\] 1\]
	    $this.dlb _sel_first \[lindex \[split %W :\] 1\]
	    $this _tag_icons
	"
	bind listimg-$this <Shift-1> "
	    [winfo toplevel $this] _selecting $this
	    $this.dlb _sel_toggle \[lindex \[split %W :\] 1\]
	    $this.dlb _sel_first \[lindex \[split %W :\] 1\]
	    $this _tag_icons
	"
	bind listimg-$this <ButtonRelease-1> \
	        [bind $this.dlb.text <ButtonRelease-1>]
	bind listimg-$this <Double-1> \
	        [bind $this.dlb.text <Double-1>]
	bind listimg-$this <ButtonPress-2> "
	    $this.dlb _sel_for_dd \[lindex \[split %W :\] 1\]
	    $this.dlb _dd_start %X %Y
	    $this _tag_icons
	    $this _selstatus
	    drag&drop drag $this.dlb.text %X %Y
	    focus $this.dlb.text
	"
	bind listimg-$this <Control-ButtonPress-2> \
	        "[bind listimg-$this <ButtonPress-2>]"
	bind listimg-$this <Control-B2-Motion> \
	    "set tkdesk(file_lb,control) 1 ;\
	    drag&drop drag $this.dlb.text %X %Y ;\
	    $this _dd_dragcmd"
	bind listimg-$this <B2-Motion> \
	    "set tkdesk(file_lb,control) 0 ;\
	    drag&drop drag $this.dlb.text %X %Y ;\
	    $this _dd_dragcmd"
	bind listimg-$this <Control-ButtonRelease-2> \
	    "set tkdesk(file_lb,control) 1 ;\
	    drag&drop drop $this.dlb.text %X %Y ;\
	    dsk_desktop_drop %X %Y ;\
	    focus -force ."
	bind listimg-$this <ButtonRelease-2> \
	    "set tkdesk(file_lb,control) 0 ;\
	    drag&drop drop $this.dlb.text %X %Y ;\
	    dsk_desktop_drop %X %Y ;\
	    focus -force ."
	bind listimg-$this <3> "
	    [bind listimg-$this <1>]
	    update idletasks
	    $this _selstatus
	    [winfo toplevel $this] _popup $this \
	    	\[$this.dlb select get\] %X %Y
	"
	bind listimg-$this <Control-3> {# nothing}

	$this _build_ls_cmd
	eval config $args
	
	$this.dlb show_hsb $longlist
    }

    destructor {
	global [set this]
	
	$this.dlb delete
        #after 10 rename $this-frame {}		;# delete this name
        catch {destroy $this}		;# destroy associated window
	::unset [set this]
    }

    #
    # ----- Methods and Procs -------------------------------------------------
    #

    method config {config} {
    }

    method cget {var} {
	return [set [string trimleft $var -]]
    }

    method curdir {} {
	return $directory
    }

    method refresh {} {
	if {$directory == ""} {
	    return
	}

	dsk_busy
	set ptag [$this.dlb tag ranges path]
	if {$ptag != ""} {
	    set pname [$this.dlb get $ptag]
	}
	set ypos [lindex [cb_old_sb_get $this.dlb.sb] 2]
	set sel [$this.dlb select getnames]
	set refreshing 1
	config -directory $directory
	set refreshing 0
	$this.dlb select name $sel
	$this.dlb _yview $ypos
	if {$ptag != ""} {
	    $this.dlb tag add path [lsearch [$this.dlb get] $pname]
	}
	dsk_lazy ;# "" 1
    }

    method clear {} {
	global tkdesk
	
	$this.mb config -text "" -state disabled
	catch "pack unpack $this.mb"
	$this.lFiles config -text ""
	$this.dlb config -list {}
	$this.dlb config -bg [cb_col $tkdesk(color,background)]
	set directory ""
    }

    method tagpath {{dir ""}} {
	global tkdesk

	# display old "open" directory in "closed" state
	set index [$this.dlb tag ranges path]
	if {$index != ""} {
	    $this.dlb tag remove path $index
	    if $add_icons {
		catch {label $this.dlb.text.l:$index}
		#incr index
		if {$closed_image != ""} {
		    $this.dlb.text.l:$index config \
			    -image $closed_image -bd 0
		} else {
		    $this.dlb.text.l:$index config \
			    -image [dsk_image $tags(dir,image)] -bd 0
		}
	    }
	}
	if {$dir == ""} {
	    return
	}

	# display new "open" directory in "opened" state
	set fname [file tail [string trimright $dir "/"]]
	if $typechar {
	    set fname $fname/
	}
	set list [$this.dlb get]
	set index [lsearch $list $fname]
	if {$index < 0} {
	    set index [lsearch -glob $list "$fname *"]
	    if {$index < 0} {
		# This happens if one listbox displays the contents
		# of a "hidden" directory.
		return
	    }
	}
	$this.dlb tag add path $index
	#incr index
	if $add_icons {
	    catch {label $this.dlb.text.l:$index}
	    set closed_image [$this.dlb.text.l:$index cget -image]
	    $this.dlb.text.l:$index config \
		    -image [dsk_image $path_image] -bd 0
	}
	# $this.dlb.text yview -pickplace $index
	$this.dlb select clear
	_tag_icons
    }

    method imginsert {tname lines} {
	global tkdesk
	
	if {$lines == ""} return
	
	if {$tname != ""} {
	    set image $tags($tname,image)
	} else {
	    set image $default_image
	}

	foreach l $lines {
	    $this.dlb.text window create [expr $l + 1].0 \
		    -create "$this create_img $l $image" -padx 2
	}
    }

    method create_img {l image} {
	catch {label $this.dlb.text.l:$l}
	$this.dlb.text.l:$l config -image [dsk_image $image] -bd 0
	bindtags $this.dlb.text.l:$l listimg-$this
	return $this.dlb.text.l:$l
    }

    method set_mask {m} {
	set mask $m
    }

    method no_mask {} {
	set invert_mask 0
	config -mask {*}
    }

    method _ask_mask {} {
	
	dsk_HistEntry .he[dsk_HistEntry :: id] \
		-title " Set Mask " \
		-label "Mask for files to show or select:" \
		-history mask_history \
		-entrydefault $_last_mask \
		-callback "$this _ask_mask_ok" \
		-addbutton "Select" \
		-addcallback "$this _ask_mask_select" \
		-checklabel "Invert Mask" \
		-checkvalue $invert_mask
    }

    method _ask_mask_ok {entry val} {
	if {$entry != ""} {
	    mask_history add $entry
	    set invert_mask $val
	    set _last_mask $entry
	    $this config -mask $entry
	}
    }

    method _ask_mask_select {entry val} {
	if {$entry != ""} {
	    mask_history add $entry
	    set invert_mask $val
	    set _last_mask $entry
	    $this.dlb select name $entry $invert_mask
	}
    }

    method command {{cmd ""} {root ""}} {
	global tkdesk

	if {$root != ""} {
	    set asr $tkdesk(exec_as_root)
	    ::set tkdesk(exec_as_root) 1
	}
	::dsk_exec_here $cmd $directory
	if {$root != ""} {
	    ::set tkdesk(exec_as_root) $asr
	}
    }

    method _build_ls_cmd {} {
	# assembles the appropriate options for dskC_ls

	#set options {-t}	;# this is always needed

	if $showall {
	    lappend options -a
	}
	if $longlist {
	    lappend options -l
	}
	if $invert {
	    lappend options -i
	}
	if $notrivialdirs {
	    lappend options -p
	}
	if $topfolders {
	    lappend options -f
	}
	if $typechar {
	    lappend options -t
	}
	switch $sort {
	    name	{lappend options -s name}
	    fold	{lappend options -s fold}
	    size	{lappend options -s size}
	    date	{lappend options -s date}
	    ext		{lappend options -s ext}
	    not		{lappend options -s not}
	}

	set ls_cmd "dskC_ls $options"
    }

    method _selstatus {} {
	global tkdesk

	if {$viewer != ""} {
	    $viewer selstatus
	}
    }

    method _dd_pkgcmd {token} {
	global tkdesk

	set tkdesk(dd_token_window) $token
	set flist [[winfo toplevel $this] select get]
	if {$flist == ""} {
	    return
	}

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

	set ll [llength $flist]
	if {$ll == 1} {
	    label $token.lFiles -text " 1 Item "
	} else {
	    label $token.lFiles -text " $ll Items "
	}
	pack $token.lFiles -anchor w

	cb_deiconify $token
	#focus $token
	return $flist
    }

    method _dd_pkgcmd_mb {token} {
	global tkdesk

	set tkdesk(dd_token_window) $token
	if {$directory != "/"} {
	    set flist [string trimright $directory /]
	} else {
	    set flist $directory
	}

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

	cb_deiconify $token
	#focus $token
	return $flist
    }

    method _dd_dragcmd {} {
	global tkdesk

	set err [catch {set token $tkdesk(dd_token_window)}]
	if $err return
	if {$tkdesk(quick_dragndrop) && [winfo exists $token.label]} {
	    if $tkdesk(file_lb,control) {
		$token.label config -text "Copying:"		
	    } else {
		$token.label config -text "Moving:"
	    }
	    update idletasks
	}
    }

    method _dd_drophandler {{win ""}} {
	global DragDrop tkdesk

	set tkdesk(drop_on_item) 1
	if ![$this.dlb _dd_end [winfo pointerx .] [winfo pointery .] 6] {
	    return
	}
	
	if {$win == ""} {
	    set win $this.dlb.text
	}

	if {$win == "$this.dlb.text"} {
	    set xy [blt_drag&drop location]
	    set x  [expr [lindex $xy 0]-[winfo rootx $this.dlb.text]]
	    set y  [expr [lindex $xy 1]-[winfo rooty $this.dlb.text]]

	    catch "wm withdraw $tkdesk(dd_token_window)"
	    update

	    set f [$this.dlb.text get "@$x,$y linestart" \
		    "@$x,$y + 1 lines linestart"]
	    set file [string trimright [lindex [split $f \t] 0]]
	    #puts $file
	    if $tkdesk(append_type_char) {
		set file [dskC_striptc $file]
	    }
	    set dest $directory
	    
	    if {$file == ".."} {
	    }
	    
	    if {$file != ""} {
		#puts $dest$file
		set isdir 0
		catch {set isdir [file isdirectory $dest$file]}
		if $isdir {
		    #set di [$this.dlb.text dlineinfo "end - 1 lines"]
		    #set maxy [expr [lindex $di 1] + [lindex $di 3]]
		    #if {$y < $maxy} {
		    set dest $dest$file/
		    #}
		    # else drop underneath last entry -> retain dest
		}
	    }
	} else {
	    # drop on menubutton above text widget
	    set dest $directory
	}

	if {$dest == ""} {
	    dsk_errbell
	    cb_error "This listbox is not a valid target (since it's empty)."
	    return
	}
	#if ![file writable $dest] {
	#    dsk_errbell
	#    if {$dest != ""} {
	#	 cb_error "You don't have write permission for this directory!"
	#    } else {
	#	 cb_error "This listbox is not a valid target (since it's empty)."
	#    }
	#    return
	#}

	#dsk_debug "Rec.: $DragDrop(file)"
	#dsk_debug "dest: $dest"
	if {[string first "$tkdesk(trashdir)/" $dest] == -1} {
	    dsk_ddcopy $DragDrop(file) $dest
	} else {
	    if !$tkdesk(quick_dragndrop) {
		dsk_delete $DragDrop(file)
	    } else {
		if {!$tkdesk(file_lb,control) && !$tkdesk(really_delete)} {
		    dsk_ddcopy $DragDrop(file) $dest
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
    }

    method _dragscroll {mode} {
	if {$mode == "press"} {
	    eval [bind Text <Button-2>]
	} else {
	    eval [bind Text <B2-Motion>]
	}
    }

    method _mb_label {} {
	global tkdesk

	set dn [file tail [string trimright $directory /] ]
	set l $dn/$mask

	set sl [string length $dn]
	# assume 12 to be the average char width...
	set mbw [winfo width $this.mb]
	if {$mbw > 1} {
	    set maxw [expr $mbw / 12]
	} else {
	    set maxw [expr $tkdesk(file_lb,width) - 10] 
	}
	if {$sl > $maxw} {
	    # leave space for "..."
	    set l "[string range $dn 0 [expr $maxw -1]].../$mask"
	}
	return $l
    }

    method _selmask {} {
	$this.dlb select name *[file extension [lindex [lindex [$this.dlb get] [$this.dlb select get]] 0]]
	$this _selstatus
    }

    method _tag_icons {} {
	global tkdesk
	
	if $add_icons {
	    if {$old_selection != ""} {
		foreach i $old_selection {
		    catch {$this.dlb.text.l:$i config \
			    -bg [cb_col $tkdesk(color,background)]}
		}
	    }
	    set old_selection [$this.dlb select get]
	    foreach i $old_selection {
		catch {$this.dlb.text.l:$i config \
			-bg [cb_col $tkdesk(color,listsel)]}
	    }
	}
    }

    method _quick_load {sel} {
	global tkdesk

	if ![info exists tkdesk(quick_load_editor)] return
	if {$sel == ""} return
	
	set file [string trimright [lindex [split [lindex [$this.dlb get] \
		[lindex $sel 0]] \t] 0] " "]
	if $tkdesk(append_type_char) {
	    set file [dskC_striptc $file]
	}
	if {[string first "/" $file] == -1} {
	    set file "$directory$file"
	}
	set isdir 0
	catch {set isdir [file isdirectory $file]}
	if !$isdir {
	    dsk_editor quickload $tkdesk(quick_load_editor) "$file"
	}
    }

    method _quick_info {sel} {
	global tkdesk

	if {$sel == ""} return
	
	set file [string trimright [lindex [split [lindex [$this.dlb get] \
		[lindex $sel 0]] \t] 0] " "]
	if $tkdesk(append_type_char) {
	    set file [dskC_striptc $file]
	}
	if {[string first "/" $file] == -1} {
	    set file "$directory$file"
	}

	set o [lindex [itcl_info objects -class dsk_FileInfo] 0]
	if {$o != {}} {
	    if {[wm state $o] == "normal"} {
		$o config -file $file
	    }
	}
    }

    proc font {fnt} {
	foreach obj [itcl_info objects -class dsk_FileListbox] {
	    if [winfo exists $obj.dlb.text] {
		$obj.dlb.text config -font [cb_font $fnt]
	    }
	}
	set lbfont $fnt
    }

    proc color {col} {
	foreach obj [itcl_info objects -class dsk_FileListbox] {
	    if [winfo exists $obj.dlb.text] {
		$obj.dlb.text config -foreground $col
	    }
	}
	set lbcolor $col
    }

    proc defimage {img} {
	set default_image $img
    }

    proc pathimage {img} {
	set path_image $img
    }

    proc showall {val} {
	set _showall $val
	foreach object [itcl_info objects -class dsk_FileListbox] {
	    if {[$object cget -showall] != $val} {
		$object config -showall $val
	    }
	}
    }

    proc longlist {val} {
	set _longlist $val
	foreach object [itcl_info objects -class dsk_FileListbox] {
	    #if {[$object cget -longlist] != $val} {
		$object config -longlist $val
	    #}
	}
    }

    proc topfolders {val} {
	set _topfolders $val
	foreach object [itcl_info objects -class dsk_FileListbox] {
	    $object config -topfolders $val
	}
    }

    proc typechar {val} {
	set _typechar $val
	foreach object [itcl_info objects -class dsk_FileListbox] {
	    $object config -typechar $val
	}
    }

    proc addicons {val} {
	set _addicons $val
	foreach object [itcl_info objects -class dsk_FileListbox] {
	    if {[$object cget -add_icons] != $val} {
		$object config -add_icons $val
	    }
	}
    }

    proc sort {val} {
	set _sort $val
	foreach object [itcl_info objects -class dsk_FileListbox] {
	    $object config -sort $val
	}
    }

	# syntax: tag create <pattern> <color> ?font?   returns tag name
	#         tag config <tagname> <color> ?font?
	#         tag reset
    proc tag {cmd args} {
	global tkdesk

	switch -glob -- $cmd {
	    create	{
		set tname filetag[incr numfiletags]
		set pat [lindex $args 0]
		if {[llength $pat] > 1} {
		    if {[lindex $pat 0] == "dir"} {
			set tags($tname,match) "[lindex $pat 1]/"
		    } else {
			set tags($tname,match) "[lindex $pat 1]\\*"
		    }
		} else {
		    set tags($tname,match) "${pat}_"
		}
		if {[winfo depth .] != 1} {
		    set tags($tname,color) [lindex $args 1]
		} else {
		    set tags($tname,color) "black"
		}
		if {[llength $args] > 2} {
		    set f  [lindex $args 2]
		    if {$f != ""} {
			set tags($tname,font) $f
		    } else {
			set tags($tname,font) $lbfont
		    }
		} else {
		    set tags($tname,font) $lbfont
		}
		if {[llength $args] > 3} {
		    set f  [lindex $args 3]
		    if {$f != ""} {
			set tags($tname,image) [lindex $args 3]
		    } else {
			set tags($tname,image) $default_image
		    }
		} elseif ![info exists tags($tname,image)] {
		    set tags($tname,image) $default_image
		}
		#eval lappend taglist $tname
		# Comment the previous line and uncomment the following two
		# to let file_tags overrule type tags.
		set di [lsearch $taglist dir]
		set taglist [linsert $taglist $di $tname]
		foreach this \
			[itcl_info objects -class dsk_FileListbox] {
		    $this.dlb tag config $tname \
			    -foreground $tags($tname,color) \
			    -font $tags($tname,font)
		}
		return $tname
	    }
	    config* {
		set tname [lindex $args 0]
		if {[winfo depth .] != 1} {
		    set tags($tname,color) [lindex $args 1]
		} else {
		    set tags($tname,color) "black"
		}
		if {[llength $args] > 2} {
		    set f  [lindex $args 2]
		    if {$f != ""} {
			set tags($tname,font) $f
		    } else {
			set tags($tname,font) $lbfont
		    }
		} else {
		    set tags($tname,font) $lbfont
		}
		if {[llength $args] > 3} {
		    set tags($tname,image) [lindex $args 3]
		} elseif ![info exists tags($tname,image)] {
		    set tags($tname,image) $default_image
		}
		foreach this \
			[itcl_info objects -class dsk_FileListbox] {
		    $this.dlb tag config $tname \
			    -foreground $tags($tname,color) \
			    -font $tags($tname,font)
		}
		if {$tname == "dir"} {
		    set tkdesk(color,directories) $tags($tname,color)
		    set tkdesk(font,directories) $tags($tname,font)
		} elseif {$tname == "symdir"} {
		    set tkdesk(color,symdirectories) $tags($tname,color)
		    set tkdesk(font,symdirectories) $tags($tname,font)
		} elseif {$tname == "exec"} {
		    set tkdesk(color,executables) $tags($tname,color)
		    set tkdesk(font,executables) $tags($tname,font)
		} elseif {$tname == "symexec"} {
		    set tkdesk(color,symexecutables) $tags($tname,color)
		    set tkdesk(font,symexecutables) $tags($tname,font)
		} elseif {$tname == "sym"} {
		    set tkdesk(color,symlinks) $tags($tname,color)
		    set tkdesk(font,symlinks) $tags($tname,font)
		}
	    }
	    reset {
		set numfiletags 0
		set taglist "dir exec sym symdir symexec"
	    }
	    default {
		error "unknown tag cmd: $cmd"
	    }
	    get {
		set ti {}
		foreach t $taglist {
		    lappend ti [list $t $tags($t,match) \
			    $tags($t,color) $tags($t,font) $tags($t,image)]
		}
		return $ti
	    }
	}
    }

    proc initC {} {
	set patlist ""
	foreach t $taglist {
	    lappend patlist $tags($t,match)
	}
	dskC_init_ftags
    }

    proc print_ready {val} {
	set print_ready $val

    }

    proc ignore {list} {
	set ignorelist $list
    }

    #
    # ----- Variables ---------------------------------------------------------
    #

    #
    #  Options for dskC_ls:
    #

    protected ls_cmd

    public invert {0} {
	$this _build_ls_cmd
	$this refresh
	::set [set this](invert) $invert
    }

    public sort {name} {
	global [set this]
	
	$this _build_ls_cmd
	$this refresh
	::set [set this](sort) $sort
    }

    public notrivialdirs {0} {
	$this _build_ls_cmd
	$this refresh
    }

    public showall {0} {
	global [set this]

	$this _build_ls_cmd
	$this refresh
	::set [set this](showall) $showall
    }

    public longlist {0} {
	global [set this]

	$this _build_ls_cmd
	$this refresh
	::set [set this](longlist) $longlist
	$this.dlb show_hsb $longlist
    }

    public topfolders {0} {
	$this _build_ls_cmd
	$this refresh
    }

    public typechar {0}	{
	$this _build_ls_cmd
	$this refresh
    }

    public add_icons {1} {
	$this refresh
	::set [set this](add_icons) $add_icons
    }

    public dont_refresh 0

    common _showall 0
    common _longlist 0
    common _topfolders 0
    common _typechar 0
    common _addicons 0
    common _sort name

    #
    #  Other
    #

    public toplevel "" {	# a hack for the file list windows
	global [set this]

	if {$toplevel != ""} {
	    $this.mb.menu delete 13	;# delete separator
	    $this.mb.menu delete 14	;# delete " Open Window "

	    $this.mb.menu insert 12 checkbutton -label " Add Icons " \
		-variable [set this](add_icons) \
	        -command "$this config -add_icons \[set [set this](add_icons)\]"
	    ::set [set this](add_icons) $add_icons
	    $this.mb.menu insert 12 checkbutton -label " Folders On Top " \
		-variable [set this](topfolders) \
	      -command "$this config -topfolders \[set [set this](topfolders)\]"
	    ::set [set this](topfolders) $topfolders

	    $this.mb.menu add separator
	    $this.mb.menu add command -label "Open Browser " \
		-command "dsk_FileViewer .fv\[dsk_FileViewer :: id\] \
			-directory \[$this info public directory -value\]"
	}
    }

    public dir {} {
	$this config -directory $dir
    }

    public directory {} {
	global tkdesk
	
	# resolve ~
	if {[string index $directory 0] == "~"} {
	    catch {set directory [glob $directory]}
	}

	if {$directory == ""} return
	dsk_busy

	# Look if there's an action to execute when this directory is opened:
	if {[info exists tkdesk(action_on_open)] && !$refreshing} {
	    set newd [string trimright $directory /]
	    set dmatch 0
	    foreach d $tkdesk(action_on_open) {
		set dp [lindex $d 0]  ;# list of patterns
		set da [lindex $d 1]  ;# Tcl script to execute
		foreach p $dp {
		    if {$p != "/"} {
			set p [string trimright [cb_tilde $p expand] /]
		    }
		    if {[string match $p $newd] || \
			    [string match [string trimright $p /*] $newd]} {
			set err [catch {eval [_expand_pc $da]} errmsg]
			if $err {
			    dsk_errbell
			    cb_error "Error while executing action from \"Directories\":\n$errmsg"
			}
			set dmatch 1
			break
		    }
		}
		if $dmatch break
	    }
	}
	
	# Look if there's button bar specifically for this directory:
	if {[info exists tkdesk(dir_button_bar)] && !$refreshing} {
	    set newd [string trimright $directory /]
	    set dmatch 0
	    foreach d $tkdesk(dir_button_bar) {
		set dp [lindex $d 0]  ;# list of patterns
		set db [lindex $d 1]  ;# Button Bar description
		foreach p $dp {
		    if {$p != "/"} {
			set p [string trimright [cb_tilde $p expand] /]
		    }
		    if {[string match $p $newd] || \
			    [string match [string trimright $p /*] $newd]} {
			[winfo toplevel $this] _create_dir_button_bar $db
			set dmatch 1
			break
		    }
		}
		if $dmatch break
	    }
	    if !$dmatch {
		[winfo toplevel $this] _remove_dir_button_bar
	    }
	}


	# read the filelist and modification time
	set err [catch {set mtime [file mtime $directory]}]
	if $err {
	    dsk_lazy
	    return
	}
	
	dsk_debug "Reading dir: $directory (with $ls_cmd)"
	dsk_status "Reading $directory ..."

	set list ""
	catch {unset mt} 	;# array for matching tags
	dskC_ls_and_tag $directory
	
	$this.dlb config -bg [cb_col $tkdesk(color,filelb)]
	dsk_debug "Done."

	if $print_ready {
	    dsk_status_ready 0
	}

    	dsk_lazy
    }

    public mask {*} {
	$this config -directory $directory
	if {$toplevel == ""} {	
	    [winfo toplevel $this] status "Ready."
	}
    }

    public width {10} {
	$this.dlb config -width $width
    }

    public height {10} {
	$this.dlb config -height $height
    }

    public pad {4} {
	$this.dlb config -pad $pad
    }

    public viewer {} {
	bind $this.dlb.text <1> "
		$viewer _selecting $this
		[bind $this.dlb.text <1>]
		bind $this.dlb.text <Any-ButtonRelease> \"$this _selstatus\""
	bind $this.dlb.text <Shift-1> "
		$viewer _selecting $this
		[bind $this.dlb.text <Shift-1>]
		bind $this.dlb.text <Any-ButtonRelease> \"$this _selstatus\""
	bind $this.dlb.text <Control-1> "
		$viewer _selecting $this
		[bind $this.dlb.text <Control-1>]
		bind $this.dlb.text <Any-ButtonRelease> \"$this _selstatus\""
	bind $this.dlb.text <2> "$viewer _selecting $this
		[bind $this.dlb.text <2>]"
	bind $this.dlb.text <3> "$viewer _selecting $this
		[bind $this.dlb.text <3>]"
    }

    protected _last_mask {*}
    protected _last_size_stat ""
    protected mtime 0
    protected refreshing 0
    protected old_selection ""
    protected closed_image ""
    protected invert_mask 0
    
    common default_image ficons16/file.xpm
    common path_image ficons16/diropen.xpm
    common lbfont fixed
    common lbcolor black
    common print_ready 1

    common ignorelist {}
    common taglist {}
    common patlist {}
    lappend taglist dir exec sym symdir symexec

    common numfiletags 0
    common tags

    set tags(dir,match) {*/}
    set tags(exec,match) {*\*}
    set tags(sym,match) {*@}
    set tags(symdir,match) {*-}
    set tags(symexec,match) {*+}

    set tags(dir,color) black
    set tags(exec,color) black
    set tags(sym,color) black
    set tags(symdir,color) black
    set tags(symexec,color) black

    set tags(dir,font) fixed
    set tags(exec,font) fixed
    set tags(sym,font) fixed
    set tags(symdir,font) fixed
    set tags(symexec,font) fixed
    
    set tags(dir,image) ficons16/dir.xpm
    set tags(exec,image) ficons16/exec.xpm
    set tags(sym,image) ficons16/sym.xpm
    set tags(symdir,image) ficons16/symdir.xpm 
    set tags(symexec,image) ficons16/symexec.xpm 
}


proc dsk_FileListbox_fileTags {} {
    global tkdesk
    
    if [info exists tkdesk(file_tags,directories)] {
	foreach tag $tkdesk(file_tags,directories) {
	    set font ""; set licon ""; set dicon ""; 
	    ot_maplist $tag pats col font licon dicon
	    catch {set col [subst $col]}
	    catch {set font [subst $font]}
	    if {$font != ""} {set font [cb_font $font]}
	    catch {set licon [subst $licon]}
	    catch {set dicon [subst $dicon]}
	    if {$pats == "!default"} {
		set tkdesk(color,directories) $col
		set tkdesk(font,directories) $font
		dsk_FileListbox :: tag config "dir" [cb_col $col] $font $licon
	    } elseif {$pats == "!symlink"} {
		set tkdesk(color,symdirectories) $col
		set tkdesk(font,symdirectories) $font
		dsk_FileListbox :: tag config "symdir" [cb_col $col] $font $licon
	    } elseif {$pats == "!opened"} {
		dsk_FileListbox :: pathimage $licon
	    } else {
		foreach pat $pats {
		    dsk_FileListbox :: tag create "dir $pat" [cb_col $col] $font $licon
		}
	    }
	}
    }

    if [info exists tkdesk(file_tags,executables)] {
	foreach tag $tkdesk(file_tags,executables) {
	    set font ""; set licon ""; set dicon ""; 
	    ot_maplist $tag pats col font licon dicon
	    catch {set col [subst $col]}
	    catch {set font [subst $font]}
	    if {$font != ""} {set font [cb_font $font]}
	    catch {set licon [subst $licon]}
	    catch {set dicon [subst $dicon]}
	    if {$pats == "!default"} {
		set tkdesk(color,executables) $col
		set tkdesk(font,executables) $font
		dsk_FileListbox :: tag config "exec" [cb_col $col] $font $licon
	    } elseif {$pats == "!symlink"} {
		set tkdesk(color,symexecutables) $col
		set tkdesk(font,symexecutables) $font
		dsk_FileListbox :: tag config "symexec" [cb_col $col] $font $licon
	    } else {
		foreach pat $pats {
		    dsk_FileListbox :: tag create "exec $pat" [cb_col $col] $font $licon
		}
	    }
	}
    }

    # this must be the last so that the other lists get precedence
    if [info exists tkdesk(file_tags)] {
	foreach tag $tkdesk(file_tags) {
	    set font ""; set licon ""; set dicon ""; 
	    ot_maplist $tag pats col font licon dicon
	    catch {set col [subst $col]}
	    catch {set font [subst $font]}
	    if {$font != ""} {set font [cb_font $font]}
	    catch {set licon [subst $licon]}
	    catch {set dicon [subst $dicon]}
	    if {$pats == "!default"} {
		dsk_FileListbox :: font $font
		dsk_FileListbox :: color [cb_col $col]
		dsk_FileListbox :: defimage $licon
	    } elseif {$pats == "!symlink"} {
		set tkdesk(color,symlinks) $col
		set tkdesk(font,symlinks) $font
		dsk_FileListbox :: tag config "sym" [cb_col $col] $font $licon
	    } else {
		foreach pat $pats {
		    dsk_FileListbox :: tag create $pat [cb_col $col] $font $licon
		}
	    }
	}
    }
    
    if [info exists tkdesk(file_tags,ignore)] {
	dsk_FileListbox :: ignore $tkdesk(file_tags,ignore)
    }

    dsk_FileListbox :: initC
}


# "System" Settings
dsk_FileListbox :: font [cb_font $tkdesk(font,file_lbs)]

dsk_FileListbox :: tag config dir \
    	[cb_col $tkdesk(color,directories)] [cb_font $tkdesk(font,directories)]
dsk_FileListbox :: tag config exec \
	[cb_col $tkdesk(color,executables)] [cb_font $tkdesk(font,executables)]
dsk_FileListbox :: tag config sym \
    	[cb_col $tkdesk(color,symlinks)] [cb_font $tkdesk(font,symlinks)]
dsk_FileListbox :: tag config symdir \
    	[cb_col $tkdesk(color,symdirectories)] [cb_font $tkdesk(font,symdirectories)]
dsk_FileListbox :: tag config symexec \
    	[cb_col $tkdesk(color,symexecutables)] [cb_font $tkdesk(font,symexecutables)]

# "Preferences" Settings
dsk_FileListbox :: showall $tkdesk(show_all_files)
dsk_FileListbox :: longlist $tkdesk(long_listing)
dsk_FileListbox :: topfolders $tkdesk(folders_on_top)
dsk_FileListbox :: typechar $tkdesk(append_type_char)
dsk_FileListbox :: addicons $tkdesk(add_icons)
dsk_FileListbox :: sort $tkdesk(default_sort)

# "FileTags" Settings
dsk_FileListbox_fileTags
