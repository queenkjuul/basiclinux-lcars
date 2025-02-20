# =============================================================================
#
# File:		dsk_FileViewer.tcl
# Project:	TkDesk
#
# Started:	11.10.94
# Changed:	21.12.96
#
# Description:	Implements a class for the main file viewer window.
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
#s    itcl_class dsk_FileViewer
#s    method config {config}
#s    method cget {var}
#s    method close {}
#s    method curdir {}
#s    method refresh {{mode ""}}
#s    method refreshdir {dir}
#s    method status {str {do_update 1}}
#s    method status_ready {{do_update 1}}
#s    method selstatus {}
#s    method select {cmd}
#s    method _set_first_lb {num}
#s    method _dblclick {lb sel}
#s    method _popup {lb sel mx my}
#s    method _resize {}
#s    method _selecting {lb}
#s    method _dd_drophandler {}
#s    method _button_bar {}
#s    proc id {{cmd ""}}
#
# =============================================================================

# this var prevents double printing of status when opening a dir:
set tkdesk(config_nostat) 0

#
# =============================================================================
#
# Class:	dsk_FileViewer
# Desc:		This creates a toplevel that is the (or a) main window
#		for the file viewer (menu, entries, listboxes etc.).
#
# Methods:	
# Procs:	
# Publics:
#

itcl_class dsk_FileViewer {
    inherit dsk_Common
    
    constructor {config} {
	global [set this] tkdesk env cb_tools

	dsk_busy
	
	#
	# Create a toplevel with this object's name
	# (later accessible as $this-top):
	#
        set class [$this info class]
        ::rename $this $this-tmp-
        ::toplevel $this -class $class
        ::rename $this $this-top
        ::rename $this-tmp- $this

	wm withdraw $this

	#
	# Create menubar
	#
	frame $this.fMenu -bd 2 -relief raised
	pack $this.fMenu -fill x
	_create_menubar $this.fMenu

	# ---- create button bar
	if {[llength $tkdesk(button_bar)] > 0} {
	    if {$tkdesk(pad) > 0} {
		frame $this.fButtonBar -bd 1 -relief raised
	    } else {
		frame $this.fButtonBar -bd 0 -relief raised
	    }
	    pack $this.fButtonBar -after $this.fMenu -fill x
	    _create_button_bar $this.fButtonBar
	}
	
	# ---- create path entry
	if {$tkdesk(pad) > 0} {
	    frame $this.fPE -bd 1 -relief raised
	} else {
	    frame $this.fPE -bd 0 -relief raised
	}
	pack $this.fPE -fill x

	entry $this.ePE -bd 2 -relief sunken
	bindtags $this.ePE "$this.ePE Entry All"
	pack $this.ePE -in $this.fPE -side left -fill x -expand yes \
		-padx $tkdesk(pad) -pady $tkdesk(pad) -ipady 2
	bind $this.ePE <Double-1> "[bind Entry <Triple-1>]; break"
	bind $this.ePE <Any-Enter> {
	    if $tkdesk(focus_follows_mouse) {focus %W}
	}
	bind $this.ePE <Return> "$this config -dir \[$this.ePE get\]"
	bind $this.ePE <Control-Return> "set tkdesk(menu,control) 1
				$this config -dir \[$this.ePE get\]
				%W delete 0 end
				%W insert end \[$this curdir\]"
	bind $this.ePE <Tab> "focus $this; break"
	bind $this.ePE <3> "update idletasks; $this _path_popup %X %Y"
	cb_bindForCompletion $this.ePE <Control-Tab>
	cb_balloonHelp $this.ePE {The path displayed in the current window. Change to visit another directory.\nThe right mouse button gives a popup menu of parent directories.}
    	blt_drag&drop target $this.ePE \
				handler text "dd_handle_text $this.ePE 1"

	frame $this.fPE.dis -width $tkdesk(pad)
	pack $this.fPE.dis -side right
	menubutton $this.mbHist -bd 2 -relief raised \
		-bitmap @$tkdesk(library)/cb_tools/bitmaps/combo.xbm \
		-menu $this.mbHist.menu
	pack $this.mbHist -in $this.fPE -side right -ipadx 2 -ipady 2

	menu $this.mbHist.menu \
		-postcommand "dir_history buildmenu $this.mbHist.menu ; update"
	# add dummy entry to work around bug in pre Tk 4.0p2:
	$this.mbHist.menu add command -label "dummy"
	dir_history changed
	bind $this.mbHist.menu <ButtonRelease-1> "
		set tkdesk(menu,control) 0
		[bind Menu <ButtonRelease-1>]"
	bind $this.mbHist.menu <Control-ButtonRelease-1> "
		set tkdesk(menu,control) 1
		[bind Menu <ButtonRelease-1>]"

	# ---- create horizontal scrollbar
	if {$tkdesk(pad) > 0} {
	    frame $this.fsb -bd 1 -relief raised
	} else {
	    frame $this.fsb -bd 0 -relief raised
	}
	pack $this.fsb -fill x
	
	scrollbar $this.hsb -orient horizontal -relief sunken \
		-command "$this _set_first_lb"
	$this.hsb set 1 3 0 2
	pack $this.hsb -in $this.fsb -fill x \
		-padx $tkdesk(pad) -pady $tkdesk(pad)
	
	#
	# ---- Create listboxes
	#
	frame $this.fLBs
	pack $this.fLBs -fill both -expand yes
	set j 0
	for {set i 0} {$i < $num_lbs} {incr i} {
	    set lbname $this.lb$j
	    incr j
	    dsk_FileListbox $lbname -viewer $this \
		-width $tkdesk(file_lb,minwidth) \
		-height $tkdesk(file_lb,minheight) -pad $tkdesk(pad)
	    update idletasks
	    pack $lbname -in $this.fLBs -side left -fill both -expand yes
	    #update
	    pack propagate $lbname 0
	}
	set num_lbs_created $j

	# ---- create status bar
	frame $this.fStatus -bd [expr $tkdesk(pad) > 0] -relief raised
	pack [set f $this.fStatus] -fill x
	label $f.l -anchor w -font [cb_font $tkdesk(font,status)]
	pack $f.l -fill x -padx [expr $tkdesk(pad) / 2] \
		-pady [expr $tkdesk(pad) / 2]

	#
	# Bindings
	#
	bind $this <Any-Enter> \
		"set tkdesk(active_viewer) $this; break"
	bind $this <Tab> "focus $this.ePE; break"

	bind $this <Control-i> "dsk_fileinfo; break"
	bind $this <Control-f> "dsk_find_files; break"
	bind $this <Control-n> "dsk_create file; break"	
	bind $this <Control-d> "dsk_create directory; break"	
	bind $this <Control-c> "dsk_copy; break"
	bind $this <Control-r> "dsk_rename; break"
	bind $this <Delete> "dsk_delete; break"
	bind $this <Control-x> "dsk_ask_exec; break"
	bind $this <Control-o> "dsk_ask_dir; break"
	bind $this <Control-b> "dsk_bookmark add; break"
	bind $this <Control-p> "dsk_print; break"
	bind $this <Return> "dsk_openall; break"
	bind $this <F1> "dsk_cbhelp $tkdesk(library)/doc/Guide howto"
	#bind $this <a><b><o><u><t> dsk_about

	#
	# Window manager settings
	#
	update idletasks
	wm title $this "TkDesk Version $tkdesk(version)"
	wm minsize $this $tkdesk(file_lb,minwidth) $tkdesk(file_lb,minheight)
	#wm geometry $this $tkdesk(file_lb,width)x$tkdesk(file_lb,height)
	dsk_place_window $this fbrowser \
		$tkdesk(file_lb,width)x$tkdesk(file_lb,height) 1
	wm protocol $this WM_DELETE_WINDOW "$this close"

	if $tkdesk(fvwm) {
	    # create the icon window
	    # (this code is based on the code posted by:
	    # kennykb@dssv01.crd.ge.com (Kevin B. Kenny))
	    toplevel $this-icon -bg [cb_col $tkdesk(color,icon)] \
		    -class Icon
	    wm withdraw $this-icon
	    label $this-icon.label \
		    -image [dsk_image $tkdesk(icon,filebrowser)] -bd 0 \
		    -bg [cb_col $tkdesk(color,icon)]
	    pack $this-icon.label -ipadx 2 -ipady 2
	    blt_drag&drop target $this-icon.label handler \
		    file "$this _dd_drophandler"
	    update idletasks
	    wm geometry $this-icon \
		    [winfo reqwidth $this-icon]x[winfo reqheight $this-icon]
	    wm protocol $this-icon WM_DELETE_WINDOW "$this delete"
	    wm iconwindow $this $this-icon
	} else {
	    wm iconbitmap $this @$tkdesk(library)/images/xbm/bigfiling.xbm
	}
	
	incr count		;# incr the counter of opened fv windows
	set tkdesk(menu,control) 0
	set tkdesk(file_lb,control) 0

        #                          
        #  Explicitly handle config's that may have been ignored earlier
        #                            
        foreach attr $config {
            config -$attr [set $attr]
        }

	dsk_sound dsk_new_filebrowser
	if !$dontmap {
	    wm deiconify $this
	    tkwait visibility $this
	    catch "lower $this .dsk_welcome"
	    update
	}

	# the status line may become quite large
	#pack propagate $this.fStatus 0
	pack propagate $this 0
	update

	dsk_lazy
    }

    destructor {
	global tkdesk
	
	for {set i 0} {$i < $num_lbs_created} {incr i} {
	    catch "$this.lb$i delete"
	}
	incr count -1
        #after 10 rename $this-top {}	;# delete this name
        catch {destroy $this}	;# destroy associated windows
	catch {destroy $this-icon}
	set tkdesk(active_viewer) ""
	foreach fv "[itcl_info objects -class dsk_FileViewer] \
		[itcl_info objects -class dsk_FileList]" {
	    if {"$fv" != "$this"} {
		set tkdesk(active_viewer) $fv
	    }
	}
    }

    #
    # ----- Methods and Procs -------------------------------------------------
    #

    method config {config} {
    }

    method cget {var} {
	return [set [string trimleft $var -]]
    }

    method close {} {
	global tkdesk env

	# add current directory to history before closing window:
	if {[string first $env(HOME) $directory] == 0} {
	    dir_history add [string_replace $directory $env(HOME) ~]
	} else {
	    dir_history add $directory
	}
	
	if [winfo exists .dsk_appbar] {
	    $this delete
	} elseif {[dsk_active viewer] == 1} {
	    # about to close last window
	    dsk_exit 1
	} else {
	    $this delete
	}
    }

    method curdir {} {
	return $directory
    }

    method refresh {{mode ""}} {
	if {$mode == "all"} {
	    foreach fv [itcl_info objects -class dsk_FileViewer] {
	    	$fv refresh
	    }
	} else {
	    for {set i 0} {$i < $num_lbs_created} {incr i} {
		set lbdirs($i) ""
	    }
	    $this config -directory $directory
	}
    }

    method refreshdir {dir} {
	#puts "refreshdir: $dir"
	for {set i 0} {$i < $dir_depth} {incr i} {
	    if {$lbdirs($i) == $dir} {
		$this.lb$i refresh
		#$this status "Ready."
		break
	    }
	}
    }

    method select {cmd args} {
	global tkdesk
	
	switch -glob -- $cmd {
	    get		{# return a list of all selected files
		set sfl ""
		for {set i 0} {$i < $dir_depth} {incr i} {
		    if ![winfo exists $this.lb$i.dlb] continue
		    set sl [$this.lb$i.dlb select get]
		    if {$sl != ""} {
		        set fl [$this.lb$i.dlb get]
			foreach s $sl {
			    set file [lindex [split [lindex $fl $s] \t] 0]
			    set file [string trimright $file " "]
			    if $tkdesk(append_type_char) {
				set file [dskC_striptc $file]
			    }
			    lappend sfl "$lbdirs($i)$file"
			}
		    }
		}
		return $sfl
			}
	    clear	{# clear selection in all listboxes
		for {set i 0} {$i < $num_lbs_created} {incr i} {
		    $this.lb$i.dlb select clear
		}
		$this selstatus
			}
	    X		{# copy selected filenames to X selection
		set sfl [$this select get] 
		if {$sfl != ""} {
		    if {$args == "names"} {
			selection handle $this "$this _retrieve_X_names"
		    } else {
			selection handle $this "$this _retrieve_X"
		    }
		    selection own $this
		} else {
		    cb_info "Please select one or more files first."
		}
			}
	    default	{
		error "$this select: unknown option $cmd"
			}
	}
    }

    method _set_first_lb {num} {
	global tkdesk
	
	# lb$num is to become the leftmost listbox
	#puts "$num, $first_lb, $dir_depth; [$this.hsb get]"

	if $tkdesk(dynamic_scrollbars) {
	    if {$dir_depth > $num_lbs} {
		pack $this.fsb -before $this.fLBs -fill x
	    } else {
		pack forget $this.fsb
	    }
	}

	if {$first_lb == $num && \
		$dir_depth == [lindex [$this.hsb get] 0]} return

	if {$num < 0} {
	    set num 0
	}

	set max_flb [cb_max 0 [expr $dir_depth - $num_lbs]]
	if {$num > $max_flb} {
	    set num $max_flb
	}

	if {$first_lb == 0 && $num == 0} {
	    $this.hsb set $dir_depth $num_lbs $first_lb \
				[expr $first_lb + $num_lbs - 1]
	    return
	}
	if {$first_lb == $max_flb && $num == $max_flb} {
	    $this.hsb set $dir_depth $num_lbs $first_lb \
				[expr $first_lb + $num_lbs - 1]
	    return
	}

	set diff [expr $num - $first_lb]
	#puts "diff: $diff"
	switch -- $diff {
	    1 {
		pack forget $this.lb$first_lb
		if {$num_lbs > 1} {
		    set i [expr $num + $num_lbs - 1]
		    pack $this.lb$i \
			    -after $this.lb[expr $num + $num_lbs - 2] \
			    -in $this.fLBs -side left -fill both \
			    -expand yes
		} else {
		    set i [expr $num + $num_lbs - 1]
		    pack $this.lb$i \
			    -in $this.fLBs -side left -fill both \
			    -expand yes
		}
		#update idletasks
		#update
		pack propagate $this.lb$i 0
	    }
	    -1 {
		pack forget $this.lb[expr $first_lb + $num_lbs - 1]
		if {$num_lbs > 1} {
		    pack $this.lb$num \
			    -before $this.lb$first_lb \
			    -side left -fill both \
			    -expand yes
		} else {
		    pack $this.lb$num \
			    -in $this.fLBs -side left -fill both \
			    -expand yes
		}
		#update idletasks
		#update
		pack propagate $this.lb$num 0
	    }
	    default	{
		for {set i $first_lb} \
			{$i < [expr $first_lb + $num_lbs]} {incr i} {
		    pack forget $this.lb$i
		}
		for {set i $num} \
			{$i < [expr $num + $num_lbs]} {incr i} {
		    pack $this.lb$i \
			    -in $this.fLBs -side left -fill both \
			    -expand yes
		    #update idletasks
		    #update
		    pack propagate $this.lb$i 0
		}
	    }
	}

	set first_lb $num
	$this.hsb set $dir_depth $num_lbs $first_lb \
				[expr $first_lb + $num_lbs - 1]

    }

    method _dblclick {lb sel} {
	global tkdesk
	
	if {$sel == "" || $lb == ""} {
	    return
	}
	if {$tkdesk(single_click) && [llength $sel] > 1} {
	    return
	}

	set dir [string trimright [$lb info public directory -value] "/"]
	#set file [lindex [lindex [$lb.dlb get] [lindex $sel 0]] 0]
	set file [string trimright [lindex [split [lindex [$lb.dlb get] \
		[lindex $sel 0]] \t] 0] " "]
	if $tkdesk(append_type_char) {
	    set file [dskC_striptc $file]
	}
	if {[string first "/" $file] == -1} {
	    set file "$dir/$file"
	}
	if {!$tkdesk(single_click) || \
		($tkdesk(single_click) && [file isdirectory $file])} {
	    ::dsk_open $this "$file"
	}
	if [file isdirectory $file] {
	    select clear
	}
    }

    method _popup {lb sel mx my} {
	if {$sel == "" || $lb == ""} {
	    return
	}
	set dir [string trimright [$lb info public directory -value] "/"]
	#set file [lindex [lindex [$lb.dlb get] [lindex $sel 0]] 0]
	set file [string trimright [lindex [split [lindex [$lb.dlb get] \
		[lindex $sel 0]] \t] 0] " "]
	::dsk_popup $lb "$dir/$file" $mx $my
	#$this selstatus
    }

    method _resize {} {
	global tkdesk [set this]

	if {$num_lbs != [set [set this](num_lbs)]} {
	    dsk_busy
	    pack propagate $this 1
	    if {$num_lbs_created < [set [set this](num_lbs)]} {
		for {set j $num_lbs_created} \
			{$j < [set [set this](num_lbs)]} {incr j} {
	    	    set lbname $this.lb$j
	    	    dsk_FileListbox $lbname -viewer $this \
			-width $tkdesk(file_lb,minwidth) -pad $tkdesk(pad)
		    update
	    	    pack $lbname -in $this.fLBs -side left \
			-fill both -expand yes
		    pack propagate $lbname 0
		}
		set num_lbs_created [set [set this](num_lbs)]
	    } else {
		$this _set_first_lb 0
		if {$num_lbs < [set [set this](num_lbs)]} {
		    for {set j $num_lbs} \
			    {$j < [set [set this](num_lbs)]} {incr j} {
		    	pack $this.lb$j -in $this.fLBs -side left \
				-fill both -expand yes
			update
			pack propagate $this.lb$j 0
		    }
		} else {
		    for {set j [set [set this](num_lbs)]} \
			    {$j < $num_lbs} {incr j} {
		    	pack forget $this.lb$j
		    }
		}
	    }
	    set num_lbs [set [set this](num_lbs)]
	    update idletasks
	    pack propagate $this 0
	    $this config -directory $directory
	    dsk_lazy
	}
    }

    method _selecting {lb} {
	global tkdesk

	if {$tkdesk(free_selection)} {
	    return
	}

	for {set i 0} {$i < $num_lbs_created} {incr i} {
	    if {"$this.lb$i" != "$lb"} {
		$this.lb$i.dlb select clear
	    }
	}
    }

    method _dd_drophandler {} {
	global DragDrop tkdesk

	catch "wm withdraw $tkdesk(dd_token_window)"
	update
	set dest $directory

	if ![file writable $dest] {
	    dsk_errbell
	    if {$dest != ""} {
	    	cb_error "You don't have write permission for this directory!"
	    } else {
		cb_error "This listbox is not a valid target (since it's empty)."
	    }
	    return
	}

	#dsk_debug "Rec.: $DragDrop(file)"
	#dsk_debug "dest: $dest"
	dsk_ddcopy $DragDrop(file) $dest
    }

    method _button_bar {} {
	_create_button_bar $this.fButtonBar
    }

    proc id {{cmd ""}} {
	if {$cmd == ""} {
	    set i $id
	    incr id
	    return $i
	} elseif {$cmd == "reset"} {
	    set id 0
	    set count 0
	}
    }

    #
    # ----- Variables ---------------------------------------------------------
    #

    public num_lbs 3

    public dontmap 0

    public dir {} {
	global tkdesk

	set err [catch {$this-top config}]
	if !$err {
	    set err [catch {set isdir [file isdirectory $dir]}]
	    if !$err {
		if !$isdir {
		    catch {set dir [_make_path_valid $dir]}
		    if ![winfo exists .dsk_welcome] {
			# don't want this during startup
			catch {dsk_bell}
			cb_alert "The path you specified is not completely valid."
		    }
		} elseif ![file readable $dir] {
		    dsk_errbell
		    cb_error "[file tail $dir]: Permission denied."
		    return
		}
	    } else {
		cb_error "Path (or user?) does not exist. Opening home directory."
		set dir ~
	    }

	    if $tkdesk(menu,control) {
		dsk_FileList .dfl[dsk_FileList :: id] -directory $dir
		set tkdesk(menu,control) 0
	    } else {
		$this config -directory $dir
	    }
	}
    }

    public directory "/" {
	global tkdesk env

	if ![winfo exists $this] return
	dsk_busy

	#set directory "[string trimright [glob $directory] "/"]/"
	set directory "[string trimright [cb_tilde $directory expand] "/"]/"
	set directory [dsk_canon_path $directory]
	dsk_debug "Directory $directory"

	set strip_i 0
	if $tkdesk(strip_home) {
	    if [string match "$env(HOME)/*" $directory] {
		set strip_i [string length "$env(HOME)"]
	    }
	}

	if [info exists tkdesk(strip_parents)] {
	    foreach d $tkdesk(strip_parents) {
		set d [string trimright $d /]
		if [string match "$d/*" $directory] {
		    set strip_i [string length $d]
		    break
		}
	    }
	}

	# determine depth of directory
	set dir_depth 0
	set first_i 0
	set cmask ""
	set l [string length $directory]
	for {set i $strip_i} {$i < $l} {incr i} {
	    if {[string index $directory $i] == "/"} {
		set ndir [string range $directory 0 $i]
		if ![info exists lbdirs($dir_depth)] {
		    set lbdirs($dir_depth) $ndir
		} elseif {$ndir != $lbdirs($dir_depth)} {
		    set lbdirs($dir_depth) $ndir
		} else {
		    catch {set cmask [$this.lb$first_i cget -mask]}
		    incr first_i
		}
		incr dir_depth
	    }
	}
	#puts $cmask
	if {$first_i == $dir_depth && $first_i} {
	    set first_i [expr $dir_depth - 1]
	}
	for {set i $dir_depth} {$i < $num_lbs_created} {incr i} {
	    set lbdirs($i) ""
	}

	#
	# fill list boxes
	#
	dsk_FileListbox :: print_ready 0
	for {set i $first_i} {$i < $dir_depth} {incr i} {
	    if {$i >= $num_lbs_created && ![winfo exists $this.lb$i]} {
	        dsk_FileListbox $this.lb$i -viewer $this \
			-width $tkdesk(file_lb,minwidth) \
			-height $tkdesk(file_lb,minheight) -pad $tkdesk(pad)
		update idletasks
		if {$cmask != ""} {
		    $this.lb$i set_mask $cmask
		}
	    }

	    $this.lb$i config -directory $lbdirs($i)
	    if {$i > 0} {
		$this.lb[expr $i - 1] tagpath $lbdirs($i)
	    }
	}
	$this.lb[expr $dir_depth - 1] tagpath

	if {$i > $num_lbs_created} {
	    set num_lbs_created $i
	} else {
	    while {$i < $num_lbs_created} {
		$this.lb$i clear
		incr i
	    }
	}

	set flb [cb_max 0 [expr $dir_depth - $num_lbs]]
	#puts "dd: $dir_depth"
	$this _set_first_lb $flb

	# add last directory to the path history:
	if {$last_directory != ""} {
	    if {[string first $env(HOME) $last_directory] == 0} {
		dir_history add [string_replace $last_directory $env(HOME) ~]
	    } else {
		dir_history add $last_directory
	    }
	}
	set last_directory $directory

	# update the path entry:
	$this.ePE delete 0 end
	$this.ePE insert end [cb_tilde $directory collapse]

	#wm title $this [cb_tilde $directory collapse]
	#wm iconname $this [file tail [string trimright $directory "/"]]/
	set_title

	if !$tkdesk(config_nostat) {
	    $this status "Ready. [dsk_fs_status $directory]"
	    #$this status "Ready."
	}
	dsk_FileListbox :: print_ready 1
	dsk_status_ready 0
	dsk_lazy
    }

    protected dir_depth 0	;# depth of the current directory
    protected first_lb 0        ;# number of leftmost listbox
    protected num_lbs_created 0	;# number of created listboxes (>= num_lbs)
    protected lbdirs		;# array of each lb's directory
    protected sb_state "packed"
    protected last_directory ""

    common count 0
    common id 0
}


