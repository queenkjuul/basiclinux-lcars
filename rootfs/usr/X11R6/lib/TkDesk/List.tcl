# =============================================================================
#
# File:		dsk_FileList.tcl
# Project:	TkDesk
#
# Started:	09.10.94
# Changed:	09.10.94
# Author:	cb
#
# Description:	Implements a class that opens a file-list toplevel.
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
#s    itcl_class dsk_FileList
#s    method config {config}
#s    method cget {var}
#s    method close {}
#s    method curdir {}
#s    method refresh {{mode ""}}
#s    method refreshdir {dir}
#s    method select {cmd}
#s    method _dblclick {lb sel}
#s    method _popup {lb sel mx my}
#s    method _selecting {lb}
#s    method _dd_drophandler {}
#s    method _button_bar {}
#s    proc id {{cmd ""}}
#
# =============================================================================

#
# =============================================================================
#
# Class:	dsk_FileList
# Desc:		Creates file-list toplevels.
#
# Methods:	
# Procs:	
# Publics:
#

itcl_class dsk_FileList {
    inherit dsk_Common

    constructor {args} {
	global tkdesk env

	dsk_busy
	
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

	frame $this.fMenu -bd 2 -relief raised
	pack $this.fMenu -fill x
	_create_menubar $this.fMenu

	# ---- Button Bar
	if {[llength $tkdesk(small_button_bar)] > 0} {
	    frame $this.fButtonBar -bd 1 -relief raised
	    pack $this.fButtonBar -after $this.fMenu -fill x
	    _create_button_bar $this.fButtonBar
	}

	# ---- Path Entry

	frame $this.fEntry -bd 1 -relief raised
	pack $this.fEntry -fill x

	entry $this.entry -bd 2 -relief sunken -width 5
	bindtags $this.entry "$this.entry Entry All"
	bind $this.entry <Double-1> "[bind Entry <Triple-1>]; break"
	bind $this.entry <Any-Enter> {
	    if $tkdesk(focus_follows_mouse) {focus %W}
	}
	bind $this.entry <Return> "
	    $this config -dir \[%W get\]
	"
	bind $this.entry <Tab> "focus $this"
	bind $this.entry <3> "update idletasks; $this _path_popup %X %Y"
	cb_bindForCompletion $this.entry <Control-Tab>
    	blt_drag&drop target $this.entry \
			handler text "dd_handle_text $this.entry 1"

	pack $this.entry -in $this.fEntry -side left -fill x \
		-expand yes -padx $pad -pady $pad -ipady 2

	frame $this.fEntry.dis -width $tkdesk(pad)
	pack $this.fEntry.dis -side right
	menubutton $this.mbHist -bd 2 -relief raised \
		-bitmap @$tkdesk(library)/cb_tools/bitmaps/combo.xbm \
		-menu $this.mbHist.menu
	pack $this.mbHist -in $this.fEntry -side right -ipadx 2 -ipady 2

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

	# --- File Listbox
	
	dsk_FileListbox $this.flb -width $tkdesk(file_lb,minwidth) \
		-height $tkdesk(file_lb,minheight) \
		-viewer $this \
		-pad $tkdesk(pad) -toplevel $this -notrivialdirs 0
	pack $this.flb -fill both -expand yes

	# ---- create status bar
	if $statbar {
	    frame $this.fStatus -bd [expr $tkdesk(pad) > 0] -relief raised
	    pack [set f $this.fStatus] -fill x
	    label $f.l -anchor w -font [cb_font $tkdesk(font,status)]
	    pack $f.l -fill x -padx [expr $tkdesk(pad) / 2] \
		    -pady [expr $tkdesk(pad) / 2]
	}

	# ---- bindings
	bind $this <Any-Enter> \
		"set tkdesk(active_viewer) $this; break"
	bind $this <Tab> "focus $this.entry; break"

	bind $this <Control-i> "dsk_fileinfo; break"
	bind $this <Control-f> "dsk_find_files; break"
	bind $this <Control-n> "dsk_create file; break"	
	bind $this <Control-d> "dsk_create directory; break"	
	bind $this <Control-c> "dsk_copy; break"
	bind $this <Control-r> "dsk_rename; break"
	bind $this <Delete> "dsk_delete; break"
	bind $this <Control-x> "dsk_ask_exec; break"
	bind $this <Control-o> "dsk_ask_dir; break"
	bind $this <Control-p> "dsk_print; break"
	bind $this <Return> "dsk_openall; break"
	bind $this <F1> "dsk_cbhelp $tkdesk(library)/doc/Guide howto"

	update idletasks
	wm title $this "File List"
	wm minsize $this $tkdesk(file_lb,minwidth) $tkdesk(file_lb,minheight)
	set w [cb_max $tkdesk(file_lb,minwidth) \
		[expr $tkdesk(file_lb,width) - 10]]
	dsk_place_window $this flist ${w}x$tkdesk(file_lb,height) 1
	wm protocol $this WM_DELETE_WINDOW "$this close"

	if $tkdesk(fvwm) {
	    # create the icon window
	    # (this code is based upon the code posted by:
	    # kennykb@dssv01.crd.ge.com (Kevin B. Kenny))
	    toplevel $this-icon -bg [cb_col $tkdesk(color,icon)] \
		    -class Icon
	    wm withdraw $this-icon
	    label $this-icon.label \
		    -image [dsk_image $tkdesk(icon,filelist)] -bd 0 \
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
	    wm iconbitmap $this @$tkdesk(library)/images/xbm/filing_open.xbm
	}

	eval config $args
	dsk_sound dsk_new_filelist

	if !$dontmap {
	    wm deiconify $this
	    tkwait visibility $this
	    catch "lower $this .dsk_welcome"
	    update
	}
	$this.entry icursor end
	$this.entry xview end
	
	pack propagate $this 0
	update

	dsk_lazy
    }

    destructor {
	global env tkdesk
	
	# add current directory to the path history:
	if {$last_directory != ""} {
	    if {[string first $env(HOME) $last_directory] == 0} {
		dir_history add [string_replace $last_directory $env(HOME) ~]
	    } else {
		dir_history add $last_directory
	    }
	}
	
	$this.flb delete
        #after 10 "rename $this-top {}"		;# delete this name
        catch {destroy $this}		;# destroy associated windows
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

    method display_statbar {display} {
	global tkdesk
	
	catch {destroy $this.fStatus}
	if $display {
	    frame $this.fStatus -bd [expr $tkdesk(pad) > 0] -relief raised
	    pack [set f $this.fStatus] -fill x
	    label $f.l -anchor w -font [cb_font $tkdesk(font,status)]
	    pack $f.l -fill x -padx [expr $tkdesk(pad) / 2] \
		    -pady [expr $tkdesk(pad) / 2]
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
	}
    }

    method refreshdir {dir} {
	global tkdesk

	if {$dir == $directory} {
	    # $this.flb config -directory $directory
	    $this.flb refresh
	    if {$directory == "$tkdesk(trashdir)/"} {
		if $tkdesk(fvwm) {
		    if {[llength [$this.flb.dlb get]] == 0} {
			$this-icon.label config \
				-image [dsk_image $tkdesk(icon,trash-empty)]
		    } else {
			$this-icon.label config \
				-image [dsk_image $tkdesk(icon,trash-full)]
		    }
		} else {
		    if {[llength [$this.flb.dlb get]] == 0} {
			wm iconbitmap $this \
				@$tkdesk(library)/images/xbm/trashcan.xbm
		    } else {
			wm iconbitmap $this \
				@$tkdesk(library)/images/xbm/trashcan_full.xbm
		    }
		}
	    }
	}
    }

    method select {cmd args} {
	global tkdesk
	
	switch -glob -- $cmd {
	    get		{# return a list of all selected files
		    set sfl ""
		    set sl [$this.flb.dlb select get]
		    if {$sl != ""} {
		        set fl [$this.flb.dlb get]
			foreach s $sl {
			    set file [lindex [split [lindex $fl $s] \t] 0]
			    set file [string trimright $file " "]
			    #if {$file == "." || $file == ".."} continue
			    if $tkdesk(append_type_char) {
				set file [dskC_striptc $file]
			    }
			    lappend sfl "$directory$file"
			}
		    }
		    return $sfl
			}
	    clear	{# clear selection in listbox
		    $this.flb.dlb select clear
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
    }

    method _selecting {lb} {
	# do nothing
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
	}

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
	}
    }

    proc status_bar {display} {
	global tkdesk
	
	foreach fl [itcl_info objects -class dsk_FileList] {
	    $fl display_statbar $display
	}
	if $display {
	    dsk_status_ready
	}
	set statbar $display
    }

    #
    # ----- Variables ---------------------------------------------------------
    #

    public dontmap 0

    public dir {} {
	global tkdesk

	if ![winfo exists $this] return

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

    public directory {} {
	global env tkdesk

	if ![string match {[~/]*} $directory] {
	    set directory [dsk_active dir]$directory
	}
	#set directory "[string trimright [glob $directory] "/"]/"
	set directory "[string trimright [cb_tilde $directory expand] "/"]/"
	set directory [dsk_canon_path $directory]
	dsk_debug "Directory $directory"

	$this.entry delete 0 end
	$this.entry insert end [cb_tilde $directory collapse]

	# right-justify the text in the path entry:
	if {[wm state $this] != "withdrawn"} {
	    $this.entry icursor end
	    $this.entry xview end
	}

	# save position of scrollbar:
	if {$last_directory != ""} {
	    set ypos($last_directory) \
		    [lindex [cb_old_sb_get $this.flb.dlb.sb] 2]
	}

	$this.flb config -directory $directory
	if [info exists ypos($directory)] {
	    $this.flb.dlb _yview $ypos($directory)
	}

	# add this directory to the path history:
	if {$last_directory != ""} {
	    if {[string first $env(HOME) $last_directory] == 0} {
		dir_history add [string_replace $last_directory $env(HOME) ~]
	    } else {
		dir_history add $last_directory
	    }
	}
	set last_directory $directory
	
	if {[string first "$tkdesk(trashdir)/" $directory] > -1} {
	    if {$directory == "$tkdesk(trashdir)/"} {
		$this.flb config -notrivialdirs 1 -showall 1
	    } else {
		$this.flb config -notrivialdirs 0 -showall 1
	    }
	    pack forget $this.fEntry
	    wm title $this Trash
	    wm iconname $this Trash
	    if $tkdesk(fvwm) {
		if {[llength [$this.flb.dlb get]] == 0} {
		    $this-icon.label config \
			    -image [dsk_image $tkdesk(icon,trash-empty)]
		} else {
		    $this-icon.label config \
			    -image [dsk_image $tkdesk(icon,trash-full)]
		}
	    } else {
		if {[llength [$this.flb.dlb get]] == 0} {
		    wm iconbitmap $this @$tkdesk(library)/images/xbm/trashcan.xbm
		} else {
		    wm iconbitmap $this \
			    @$tkdesk(library)/images/xbm/trashcan_full.xbm
		}
	    }
	} else {
	    if {[wm title $this] == "Trash"} {
		$this.flb config -notrivialdirs 0
		pack $this.fEntry -fill x -after $this.fButtonBar
	    }
	    #set wt [file tail [string trimright $directory "/"]]/
	    #wm title $this $wt
	    #wm iconname $this $wt
	    set_title
	    if $tkdesk(fvwm) {
		$this-icon.label config \
			-image [dsk_image $tkdesk(icon,filelist)]
	    } else {
		wm iconbitmap $this @$tkdesk(library)/images/xbm/filing_open.xbm
	    }
	}

	if !$height_set {
	    set height_set 1
	    set h [cb_max [cb_min [expr [llength [$this.flb.dlb get]] + 1] \
		    $tkdesk(file_lb,height)] $tkdesk(file_lb,minheight)]
	    set w [cb_max $tkdesk(file_lb,minwidth) \
		    [expr $tkdesk(file_lb,width) - 10]]
	    wm geometry $this ${w}x$h
	}
    }

    public pad {4} {
    }

    protected height_set 0
    protected last_directory ""
    protected ypos

    common id 0
    common statbar 0
}


