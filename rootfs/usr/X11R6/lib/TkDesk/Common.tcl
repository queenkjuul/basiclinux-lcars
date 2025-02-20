# =============================================================================
#
# File:		dsk_Common.tcl
# Project:	TkDesk
#
# Started:	17.09.96
# Changed:	17.09.96
# Author:	cb
#
# Description:	Defines mega-widgets common to both file browser and
#               file list windows (i.e. menu bar, button bar).
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
#s    itcl_class dsk_Common
#s    method config {config} {}
#s    method configure {config} {}
#s    method cget {pubvar}
#s    method _create_menubar {frame}
#s    method _create_button_bar {frame {bbdesc ""}}
#s    method _create_dir_button_bar {desc}
#s    method _remove_dir_button_bar {}
#s    method _retrieve_X {offset maxBytes}
#s    method set_title {}
#s    method _expand_title {title}
#s    method _path_popup {x y}
#s    method textview {file}
#
# =============================================================================

# -----------------------------------------------------------------------------
# CLASS: dsk_CommonMenuBar:
# Implements the menu bar of file browser/list windows.
#

itcl_class dsk_Common {
    
    constructor {config} {
    }

    destructor {
    }

    #
    # ----- Methods and Procs -------------------------------------------------
    #

    method config {config} {}
    method configure {config} {}
    
    method cget {pubvar} {
	return [virtual set [string trimleft $pubvar -]]
    }

    method status {str {do_update 1}} {
	pack propagate $this 0
	if ![winfo exists $this.fStatus.l] return
	$this.fStatus.l config -text $str
	if $do_update {
	    update ;# idletasks
	}
    }

    method status_ready {{do_update 1}} {
	pack propagate $this 0
	if ![winfo exists $this.fStatus.l] return
	$this.fStatus.l config -text \
          "Ready. [dsk_fs_status [_make_path_valid [virtual cget -directory]]]"
	if $do_update {
	    update ;# idletasks
	}
    }

    method selstatus {} {
	global tkdesk
	
	if ![winfo exists $this.fStatus.l] return
	set sfl [virtual select get]
	set l [llength $sfl]
	if {$l == 0} {
	    $this status "Ready. [dsk_fs_status [virtual cget -directory]]"
	    #$this status "Ready."
	} elseif {$l == 1} {
	    set fi ""
	    catch {set fi [dskC_ls -l -o [lindex $sfl 0]]}
	    if {$fi != ""} {
		set fi [split [lindex $fi 0] \t]
		if {[lindex $fi 7] == ""} {
		    ot_maplist $fi n s d o g p l
		    set n [dskC_unesc [string trimright $n " "]]
		    $this status "$n:  $s Bytes,  $d,  $o/$g  ($p)"
		} else {
		    # it's a symbolic link
		    set n [dskC_unesc [string trimright [lindex $fi 0] " "]]
		    set lf [lindex [lindex $fi 7] 1]
		    $this status "$n: symbolic link to $lf"
		}
	    } else {
		$this status "[file tail $sfl]: broken symbolic link"
	    }
	} else {
	    set s 0

	    # sum up file sizes - another candidate for C coding
	    foreach f $sfl {
		catch {set s [expr $s + [file size $f]]}
	    }
	    $this status "$l Items selected ($s Bytes)."
	}
    }

    method _create_menubar {frame} {
	global [set this] tkdesk env cb_tools

	# ---- TkDesk Menu
	if [$this isa dsk_FileViewer] {
	    menubutton $frame.mbTkDesk -text "TkDesk" -underline 0 \
		    -menu $frame.mbTkDesk.menu
	    pack $frame.mbTkDesk -side left
	    
	    menu [set m $frame.mbTkDesk.menu]
	} else {
	    menubutton $frame.mbOthers -text "Others" -underline 0 \
		    -menu $frame.mbOthers.menu
	    menu $frame.mbOthers.menu
	    menu [set m $frame.mbOthers.menu.tkdesk]
	}
	
	set tkdesk_menu $m
	if $tkdesk(in_development) {
	    $m add cascade -label "Development" \
		    -menu [set dm $m.dmenu]
	    $m add separator
	    menu $dm -tearoff 1
	    $dm add command -label "Eval XSelection " \
		    -command {eval [selection get]} \
		    -accelerator "Meta-x"
	    $dm add command -label "Restart" -underline 2 \
		    -command "dsk_restart" -accelerator "Meta-r"
	    $dm add separator
	    $dm add checkbutton -label "Debug Mode" \
		    -variable tkdesk(debug)
	    $dm add command -label "Debug tkdesksh" -command "
	    exec rxvt -e gdb /home/root/tcl/TkDesk/tkdesksh [pid] &
	    "
	    
	    bind $this <Alt-x> {eval [selection get]; bell}
	    bind $this <Alt-r> {dsk_restart}
	}
	$m add command -label "New Browser..." -underline 0 \
		-command "dsk_ask_dir browser"
	if [$this isa dsk_FileViewer] {
	    $m add command -label "Clone Window" -underline 2 \
		    -command "dsk_FileViewer .fv\[dsk_FileViewer :: id\] \
		    -dir \[$this curdir\] -num_lbs \[$this cget num_lbs\]"
	} else {
	    $m add command -label "Clone Window" -underline 2 \
		    -command "dsk_FileList .fl\[dsk_FileList :: id\] \
		    -dir \[$this curdir\]"
	}
	if [winfo exists .dsk_appbar] {
	    $m add command -label "Hide AppBar" -underline 0 \
		    -command "dsk_appbar"
	} else {
	    $m add command -label "Display AppBar" -underline 0 \
		    -command "dsk_appbar"
	}
	$m add separator
	$m add cascade -label "Configuration " -underline 0 \
		-menu $m.edmenu
	$m add cascade -label "Auto Save" -underline 1 \
		-menu $m.aumenu		
	$m add command -label "Save All Now" -underline 0 \
		-command {dsk_save_config 1}

	$m add separator
	$m add command -label "Close Window" -underline 0 \
		-command "$this close"
	if !$tkdesk(xmaster) {
	    $m add command -label "Quit" -underline 0 -command "dsk_exit"
	} else {
	    $m add command -label "Quit X Windows" -underline 0 \
		    -command "dsk_exit"
	}
	
	menu [set em $m.edmenu]
	$em add command -label "All" -command "dsk_edit_configs"
	$em add separator
	foreach cf $tkdesk(configfiles) {
	    $em add command -label $cf -command "dsk_edit_configs $cf"
	}

	menu [set am $m.aumenu]
	$am add checkbutton -label "Annotations" \
		-variable tkdesk(autosave,annotations)
	$am add checkbutton -label "Bookmarks" \
		-variable tkdesk(autosave,bookmarks)
	$am add checkbutton -label "Histories" \
		-variable tkdesk(autosave,history)
	$am add checkbutton -label "Options" \
		-variable tkdesk(autosave,options)
	$am add checkbutton -label "Window Layout" \
		-variable tkdesk(autosave,layout)

	# ---- File Menu
	menubutton $frame.mbFile -text "File" -underline 0 \
		-menu $frame.mbFile.menu
	pack $frame.mbFile -side left

	menu [set m $frame.mbFile.menu]
	$m add command -label "Information" -underline 0 \
		-command "dsk_fileinfo" -accelerator "Ctrl-i"
	$m add command -label "New File..." -underline 0 \
		-command "dsk_create file" -accelerator "Ctrl-n"
	$m add command -label "New Directory..." -underline 4 \
		-command "dsk_create directory" -accelerator "Ctrl-d"
	$m add separator
	$m add command -label "Open" -underline 0 \
		-command "dsk_openall"
	$m add command -label "Print..." -underline 0 \
		-command "dsk_print" -accelerator "Ctrl-P"
	$m add command -label "Copy, Move, Link... " -underline 0 \
		-command "dsk_copy" -accelerator "Ctrl-c"
	$m add command -label "Rename... " -underline 0 \
		-command "dsk_rename" -accelerator "Ctrl-r"
	$m add command -label "Delete..." -underline 1 \
		-command "dsk_delete" -accelerator "Del"
	
	$m add separator
	$m add command -label "Find Files..." -underline 0 \
		-command "dsk_find_files" -accelerator "Ctrl-f"
	$m add command -label "Find Annotation..." -underline 5 \
		-command "dsk_find_annotation"
	$m add command -label "Copy To X Selection" -underline 8 \
		 -command "dsk_select X"
	$m add command -label "Copy Names Only " -underline 6 \
		 -command "dsk_select X names"
	$m add separator
	$m add cascade -label "History" -menu $m.mhf
	menu $m.mhf -postcommand \
		"file_history buildmenu $m.mhf; update"
	# add dummy entry to work around bug in pre Tk 4.0p2:
	$m.mhf add command -label "dummy"
	file_history changed
	bind $m.mhf <ButtonRelease-3> "
	set tkdesk(file_lb,control) 0
	[bind Menu <ButtonRelease-3>]"
	bind $m.mhf <Control-ButtonRelease-3> "
	set tkdesk(file_lb,control) 1
	[bind Menu <ButtonRelease-3>]"
	$m add command -label "Close Window" -command "$this delete"
	
	# ---- Directories Menu
	menubutton $frame.mbDirs -text "Directory" -underline 0 \
		-menu $frame.mbDirs.menu
	pack $frame.mbDirs -side left

	menu [set m $frame.mbDirs.menu]
	$m add command -label "Open..." -underline 0 \
		-command "dsk_ask_dir" -accelerator "Ctrl-o"
	$m add command -label "New..." -underline 0 \
		-command "dsk_create directory" -accelerator "Ctrl-d"
	$m add command -label "Home Directory " -underline 0 \
		-command "$this config -dir \$env(HOME)"
	
	$m add command -label "Open Trash Can" -underline 0 \
		-command "dsk_FileList .dfl\[dsk_FileList :: id\] \
			-directory $tkdesk(trashdir)"
	$m add command -label "Empty Trash Can" -underline 0 \
		-command "dsk_empty_trash"
	
	$m add separator
	if [info exists tkdesk(directories)] {
	    foreach mdir $tkdesk(directories) {
		if {$mdir == "-"} {
		    $m add separator
		} else {
		    _add_dir_to_menu $this $m $mdir
		}
	    }
	}

	$m add separator
	$m add cascade -label "Trees" -menu ${m}.fs
	menu ${m}.fs
	menu ${m}.fs.home -postcommand "dsk_casdirs $env(HOME) ${m}.fs.home 1"
	${m}.fs add cascade -label "Home " -menu ${m}.fs.home
	menu ${m}.fs.root -postcommand "dsk_casdirs / ${m}.fs.root 1"
	${m}.fs add cascade -label "Root " -menu ${m}.fs.root

	$m add cascade -label "History" -menu $m.mhd
	menu $m.mhd -postcommand \
		"dir_history buildmenu $m.mhd open; update"
	# add dummy entry to work around bug in pre Tk 4.0p2:
	$m.mhd add command -label "dummy"
	dir_history changed

	bind $m <ButtonRelease-1> "
		set tkdesk(menu,control) 0
		[bind Menu <ButtonRelease-1>]"
	bind $m <Control-ButtonRelease-1> "
		set tkdesk(menu,control) 1
		[bind Menu <ButtonRelease-1>]"

	# ---- Others Menu (FileList)
	if [$this isa dsk_FileList] {
	    pack $frame.mbOthers -side left

	    set m $frame.mbOthers.menu
	    if $tkdesk(in_development) {
		$m add cascade -label "Development" \
			-menu [set dm $frame.mbOthers.menu.dmenu]
		$m add separator
		menu $dm
		$dm add command -label "Eval XSelection " \
			-command {eval [selection get]} \
			-accelerator "Meta-x"
		$dm add command -label "Restart" -underline 2 \
			-command "dsk_restart" -accelerator "Meta-r"
		$dm add command -label "Debug tkdesksh" -command "
		exec rxvt -e gdb /home/root/tcl/TkDesk/tkdesksh [pid] &
		"

		bind $this <Alt-x> {eval [selection get]; bell}
		bind $this <Alt-r> {dsk_restart}
	    }
	    #$m add command -label "Open Browser View" -underline 0 \
		    -command "dsk_FileViewer .fv\[dsk_FileViewer :: id\] \
		    -dir \[$this curdir\] -num_lbs \$tkdesk(num_lbs)"
	    $m add cascade -label "TkDesk" -menu $frame.mbOthers.menu.tkdesk
	    $m add cascade -label "Commands" -menu $frame.mbOthers.menu.cmd
	    $m add cascade -label "Bookmarks" -menu $frame.mbOthers.menu.book
	    $m add cascade -label "Options" -menu $frame.mbOthers.menu.opts
	    $m add cascade -label "Help" -menu $frame.mbOthers.menu.help
	    $m add separator
	    $m add command -label "Open Browser " \
		    -command "dsk_FileViewer .fv\[dsk_FileViewer :: id\] \
	                -directory \[$this info public directory -value\]"
	}

	# ---- Commands Menu
	if [$this isa dsk_FileViewer] {
	    menubutton $frame.mbCmds -text "Commands" -underline 0 \
		    -menu $frame.mbCmds.menu
	    pack $frame.mbCmds -side left
	    menu [set m $frame.mbCmds.menu]
	} else {
	    menu [set m $this.fMenu.mbOthers.menu.cmd]
	}
	$m add command -label "Execute..." -underline 0 \
		-command "dsk_ask_exec" -accelerator "Ctrl-x"
	$m add command -label "Execute as root..." -underline 11 \
		-command "$this exec_as_root"
	$m add command -label "Periodic Execution..." -underline 0 \
		-command "dsk_periodic"
	$m add command -label "Job Control" -underline 0 -command "dsk_jobs"
	$m add separator
	$m add command -label "Edit File..." -underline 0 \
		-command {dsk_edit}
	$m add command -label "New File" -underline 0 \
		-command {dsk_edit "New File"}
	$m add command -label "Edit Selected" -underline 0 \
		-command {eval [_expand_pc {dsk_edit %B}]}
	$m add cascade -label "Buffers" -menu $m.bufs
	menu [set tm $m.bufs] -postcommand \
		"dsk_Editor :: bufferMenu $tm"
	$m add separator
	if [info exists tkdesk(commands)] {
	    foreach cmd $tkdesk(commands) {
		if {[llength $cmd] > 1} {
		    _add_cmd_to_menu $m $cmd
		} else {
		    $m add separator
		}
	    }
	}

	$m add separator
	$m add cascade -label "History" -menu $m.mhe
	menu $m.mhe -postcommand \
		"exec_history buildmenu $m.mhe; update"
	# add dummy entry to work around bug in pre Tk 4.0p2:
	$m.mhe add command -label "dummy"
	exec_history changed
	bind $m.mhe <ButtonRelease-3> "
	set tkdesk(file_lb,control) 0
	[bind Menu <ButtonRelease-3>]"
	bind $m.mhe <Control-ButtonRelease-3> "
	set tkdesk(file_lb,control) 1
	[bind Menu <ButtonRelease-3>]"

	# ---- Bookmarks Menu
	if [$this isa dsk_FileViewer] {
	    menubutton $frame.mbBook -text "Bookmarks" -underline 0 \
		    -menu $frame.mbBook.menu
	    pack $frame.mbBook -side left
	    menu [set m $frame.mbBook.menu] \
		    -postcommand "dsk_bookmark menu $m"
	} else {
	    menu [set m $this.fMenu.mbOthers.menu.book] \
		    -postcommand "dsk_bookmark menu $m"
	}
	
	# add dummy entry to work around bug in pre Tk 4.0p2:
	$m add command -label "dummy"
	bind $m <ButtonRelease-1> "
		set tkdesk(file_lb,control) 0
		[bind Menu <ButtonRelease-1>]"
	bind $m <Control-ButtonRelease-1> "
		set tkdesk(file_lb,control) 1
		[bind Menu <ButtonRelease-1>]"

	# ---- Options Menu
	if [$this isa dsk_FileViewer] {
	    menubutton $frame.mbOpts -text "Options" -underline 0 \
		    -menu $frame.mbOpts.menu
	    pack $frame.mbOpts -side left
	    menu [set m $frame.mbOpts.menu]
	} else {
	    menu [set m $this.fMenu.mbOthers.menu.opts]
	}
	
	$m add checkbutton -label " Long Listing " -underline 1 \
	    -variable tkdesk(long_listing) \
	    -command "dsk_FileListbox :: longlist \$tkdesk(long_listing)"
	$m add checkbutton -label " Show All Files " -underline 1 \
	    -variable tkdesk(show_all_files) \
	    -command "dsk_FileListbox :: showall \$tkdesk(show_all_files)"
	$m add checkbutton -label " Add Icons " -underline 1 \
	    -variable tkdesk(add_icons) \
	    -command "dsk_FileListbox :: addicons \$tkdesk(add_icons)"
	$m add checkbutton -label " Folders On Top " -underline 1 \
	    -variable tkdesk(folders_on_top) \
	    -command "dsk_FileListbox :: topfolders \$tkdesk(folders_on_top)"
	$m add checkbutton -label " Append Type Char " -underline 2 \
	    -variable tkdesk(append_type_char) \
	    -command "dsk_FileListbox :: typechar \$tkdesk(append_type_char)"
	$m add checkbutton -label " Single Click (Dirs) " -underline 4 \
	    -variable tkdesk(single_click)
	$m add checkbutton -label " Always In Browser " -underline 11 \
	    -variable tkdesk(in_browser)
	$m add checkbutton -label " Status in List Windows " -underline 5 \
	    -variable tkdesk(list_statbar) \
	    -command "dsk_FileList :: status_bar \$tkdesk(list_statbar)"
	$m add cascade -label "Sort by ..." -menu $m.smenu
	menu $m.smenu
	$m.smenu add radiobutton -label " Name " \
		-variable tkdesk(default_sort) -value name \
		-command "dsk_FileListbox :: sort \$tkdesk(default_sort)"
	$m.smenu add radiobutton -label " Name (fold) " \
		-variable tkdesk(default_sort) -value fold \
		-command "dsk_FileListbox :: sort \$tkdesk(default_sort)"
	$m.smenu add radiobutton -label " Size " \
		-variable tkdesk(default_sort) -value size \
		-command "dsk_FileListbox :: sort \$tkdesk(default_sort)"
	$m.smenu add radiobutton -label " Date " \
		-variable tkdesk(default_sort) -value date \
		-command "dsk_FileListbox :: sort \$tkdesk(default_sort)"
	$m.smenu add radiobutton -label " Extension " \
		-variable tkdesk(default_sort) -value ext \
		-command "dsk_FileListbox :: sort \$tkdesk(default_sort)"
	$m.smenu add radiobutton -label " Don't sort " \
		-variable tkdesk(default_sort) -value not \
		-command "dsk_FileListbox :: sort \$tkdesk(default_sort)"
	$m add separator

	#$m add checkbutton -label " Execute as root " -underline 2 \
	#    -variable tkdesk(exec_as_root)
	$m add checkbutton -label " Strip $env(HOME) " -underline 2 \
	    -variable tkdesk(strip_home) \
	    -command "$this refresh all"
	$m add checkbutton -label " Overwrite Always " -underline 1 \
	    -variable tkdesk(overwrite_always)
	$m add checkbutton -label " Really Delete " -underline 1 \
	    -variable tkdesk(really_delete)
	$m add checkbutton -label " Ask On Delete " -underline 3 \
	    -variable tkdesk(ask_on_delete)
	$m add checkbutton -label " Quick Drag'n'Drop " -underline 1 \
	    -variable tkdesk(quick_dragndrop)
	$m add checkbutton -label " Sort History " -underline 6 \
	    -variable tkdesk(sort_history)
	$m add checkbutton -label " TkDesk Server " -underline 4 \
		-command "dsk_setup_server" -variable tkdesk(tkdesk_server)
	$m add checkbutton -label " Dialogs At Pointer " -underline 1 \
	    -variable tkdesk(at_pointer)
	$m add checkbutton -label " Autoraise AppBar " \
		-variable tkdesk(appbar,autoraise)
	$m add checkbutton -label " Use Sound " -underline 8 \
		-variable tkdesk(use_sound)
	if ![info exists tkdesk(soundcmd)] {
	    $m entryconfig [$m index *Sound*] -state disabled
	}
	#$m add separator
	set optm $m

	if [$this isa dsk_FileViewer] {
	    $m add cascade -label "Number Of Listboxes" -menu $m.numlbs
	    menu [set m $m.numlbs]
	    set num_lbs [virtual cget -num_lbs]
	    set [set this](num_lbs) $num_lbs
	    $m add radiobutton -label " 1 Listbox" \
		    -variable [set this](num_lbs) \
		    -value 1 -command "$this _resize"
	    $m add radiobutton -label " 2 Listboxes" \
		    -variable [set this](num_lbs) \
		    -value 2 -command "$this _resize"
	    $m add radiobutton -label " 3 Listboxes" \
		    -variable [set this](num_lbs) \
		    -value 3 -command "$this _resize"
	    $m add radiobutton -label " 4 Listboxes" \
		    -variable [set this](num_lbs) \
		    -value 4 -command "$this _resize"
	    $m add radiobutton -label " 5 Listboxes" \
		    -variable [set this](num_lbs) \
		    -value 5 -command "$this _resize"
	    $m add radiobutton -label " 6 Listboxes" \
		    -variable [set this](num_lbs) \
		    -value 6 -command "$this _resize"
	}

	set m $optm
	$m add separator
	$m add checkbutton -label "Balloon Help" \
		-variable cb_tools(balloon_help)
	$m add checkbutton -label "Use Netscape for Help" \
		-variable tkdesk(netscape_help)

	# ---- Help Menu
	if [$this isa dsk_FileViewer] {
	    menubutton $frame.mbHelp -text "Help" -underline 0 \
		    -menu $frame.mbHelp.menu
	    pack $frame.mbHelp -side right
	    menu [set m $frame.mbHelp.menu]
	} else {
	    menu [set m $this.fMenu.mbOthers.menu.help]
	}

	$m add command -label "User's Guide  " \
		-command "dsk_help guide" \
		-accelerator "F1"
	$m add command -label "Manual Page... " \
		-command "dsk_man"
	$m add separator
	$m add command -label "Getting Started" \
		-command "dsk_help quick"
	$m add command -label "TkDesk FAQ" \
		-command "dsk_help faq"
	$m add command -label "Changes" \
		-command "dsk_help changes"
	$m add command -label "License" \
		-command "dsk_help license"
	$m add separator
	$m add command -label "About TkDesk..." \
		-command dsk_about
    }


    method _create_button_bar {frame {bbdesc ""}} {
	global tkdesk

	if {$bbdesc == ""} {
	    if [$this isa dsk_FileViewer] {
		set bbdesc $tkdesk(button_bar)
	    } else {
		set bbdesc $tkdesk(small_button_bar)
	    }
	}

	catch {destroy $frame.fBB}
	frame $frame.fBB
	pack $frame.fBB -fill x

	set bcnt 0
	set fcnt 0
	frame $frame.fBB.f$fcnt
	pack  $frame.fBB.f$fcnt -fill x -padx $tkdesk(pad) -pady $tkdesk(pad)
	foreach but $bbdesc {
	    if {[llength $but] == 1} {
		if {$but == "break" || $but == "\\n"} {
		    incr fcnt
		    frame $frame.fBB.f$fcnt
		    pack  $frame.fBB.f$fcnt -fill x \
			    -padx $tkdesk(pad) -pady $tkdesk(pad)
		} else {
		    frame $frame.fBB.f$fcnt.f$bcnt -width $tkdesk(pad)
		    pack $frame.fBB.f$fcnt.f$bcnt -side left \
			    -padx $tkdesk(pad) -pady $tkdesk(pad)
		    incr bcnt
		}
		continue
	    }

	    set bitmap [lindex $but 0]
	    set bgcolor [cb_col $tkdesk(color,background)]
	    set fgcolor [cb_col $tkdesk(color,foreground)]
	    if {[llength $bitmap] > 1} {
		if {[lindex $bitmap 1] != ""} {
		    set fgcolor [lindex $bitmap 1]
		}
		if {[llength $bitmap] > 2} {
		    if {[lindex $bitmap 2] != ""} {
			set bgcolor [lindex $bitmap 2]
		    }
		}
		set bitmap [lindex $bitmap 0]
	    }

	    #set action [string_replace [lindex $but 1] \" \\\"]
	    set action [lindex $but 1]

	    set desc ""
	    if {[llength $action] > 1} {
		set desc [lindex $action 1]
		set action [lindex $action 0]
	    }
	    dsk_debug "BB$bcnt action: $action"

	    button $frame.fBB.f$fcnt.b$bcnt \
		    -image [dsk_image $bitmap -background $bgcolor \
		    -foreground $fgcolor] \
		    -takefocus 0 -highlightthickness 0 \
		    -command "cd \[dsk_active dir\] ;\
		              set tkdesk(error_source) {ButtonBar} ;\
			      eval \[_expand_pc \"[dskC_esc $action \[\]\$\"]\"\];\
			      set tkdesk(error_source) {} ;\
			      cd ~"
	    pack $frame.fBB.f$fcnt.b$bcnt -side left \
		    -padx 0 -pady 0 \
		    -ipadx 2 -ipady 2

	    if {$desc != ""} {
		cb_balloonHelp $frame.fBB.f$fcnt.b$bcnt "$desc"
	    }

	    incr bcnt
	}
    }

    method _create_dir_button_bar {desc} {
	pack propagate $this 0
	if ![winfo exists $this.fDirBB] {
	    frame $this.fDirBB -bd 1 -relief raised
	} else {
	    pack propagate $this.fDirBB 0
	    destroy $this.fDirBB.fBB
	}
	if [winfo exists $this.fButtonBar] {
	    pack $this.fDirBB -after $this.fButtonBar -fill x
	} else {
	    pack $this.fDirBB -after $this.fMenu -fill x
	}

	_create_button_bar $this.fDirBB $desc
	#pack propagate $this.fDirBB 1
    }
    
    method _remove_dir_button_bar {} {
	catch {destroy $this.fDirBB}
    }
    
    method _retrieve_X {offset maxBytes} {
	# return "offset: $offset, maxBytes: $maxBytes"

	if {$offset != 0} {
	    # this should never happen, so return
	    return ""
	}

	set sfl [$this select get]
	set rl ""
	if {$sfl != ""} {
	    if {[llength $sfl] > 1} {
	    	foreach file $sfl {
		    if {[llength $file] > 1} {
			append rl "\"$file\" "
		    } else {
			append rl "$file "
		    }
	    	}
	    } else {
		set rl $sfl
	    }
	}
	if {[string length $rl] > $maxBytes} {
	    return [string range $rl 0 [expr $maxBytes - 1]]
	} else {
	    return $rl
	}
    }

    method _retrieve_X_names {offset maxBytes} {
	# return "offset: $offset, maxBytes: $maxBytes"

	if {$offset != 0} {
	    # this should never happen, so return
	    return ""
	}

	set sfl [$this select get]
	set rl ""
	if {$sfl != ""} {
	    if {[llength $sfl] > 1} {
	    	foreach file $sfl {
		    set file [file tail $file]
		    if {[llength $file] > 1} {
			append rl "\"$file\" "
		    } else {
			append rl "$file "
		    }
	    	}
	    } else {
		set rl [file tail $sfl]
	    }
	}
	if {[string length $rl] > $maxBytes} {
	    return [string range $rl 0 [expr $maxBytes - 1]]
	} else {
	    return $rl
	}
    }

    method set_title {} {
	global tkdesk

	if [$this isa dsk_FileViewer] {
	    set title $tkdesk(title,browser)
	} else {
	    set title $tkdesk(title,list)
	}
	wm title $this [_expand_title $title]

	set title $tkdesk(title,icon)
	wm iconname $this [_expand_title $title]
    }

    method exec_as_root {} {
	global tkdesk

	set asr $tkdesk(exec_as_root)
	::set tkdesk(exec_as_root) 1
	::dsk_ask_exec
	::set tkdesk(exec_as_root) $asr
    }

    method _expand_title {title} {
	global tkdesk

	if {[string first "%d" $title] > -1} {
	    regsub "%d" $title \
		    [file tail [string trimright \
		    [virtual cget -directory] "/"]]/ title
	}
	if {[string first "%h" $title] > -1} {
	    regsub "%h" $title [dsk_hostname] title
	}
	if {[string first "%p" $title] > -1} {
	    regsub "%p" $title [cb_tilde [virtual cget -directory] collapse] \
		    title
	}
	if {[string first "%u" $title] > -1} {
	    regsub "%u" $title [dsk_logname] title
	}
	if {[string first "%v" $title] > -1} {
	    regsub "%v" $title $tkdesk(version) title
	}

	return $title
    }

    method _path_popup {x y} {
	global tkdesk
	
	set m $this-ppop
	catch {destroy $m}
	menu $m
	bind $m <ButtonRelease-3> "
		set tkdesk(menu,control) 0
		[bind Menu <ButtonRelease-3>]"
	bind $m <Control-ButtonRelease-3> "
		set tkdesk(menu,control) 1
		[bind Menu <ButtonRelease-3>]"
	
	set p [cb_tilde [string trimright \
		[virtual cget -directory] "/"] collapse]
	if {$p != ""} {
	    set op $p
	    while {1} {
		set p [file dirname $p]
		$m add command -label $p \
			-command "$this config -dir [list $p]" \
			-font [cb_font $tkdesk(font,file_lbs)]
		if {$p == "/"} break
	    }
	    $m add separator
	    
	    set sm $m.sub
	    $m add cascade -label "Subdirectories " -menu $sm
	    menu $sm
	    set p $op
	    set i 0
	    while {1} {
		set p [file dirname $p]
		set cm $sm.cas$i
		$sm add cascade -label $p -menu $cm \
			-font [cb_font $tkdesk(font,file_lbs)]
		catch {destroy $cm}
		menu $cm -postcommand "dsk_casdirs [list $p] $cm 1"
		incr i
		if {$p == "/"} break
	    }
	    
	    set sm $m.files
	    $m add cascade -label "... and Files " -menu $sm
	    menu $sm
	    set p $op
	    set i 0
	    while {1} {
		set p [file dirname $p]
		set cm $sm.cas$i
		$sm add cascade -label $p -menu $cm \
			-font [cb_font $tkdesk(font,file_lbs)]
		catch {destroy $cm}
		menu $cm -postcommand "dsk_casdirs [list $p] $cm 1 {} 1"
		incr i
		if {$p == "/"} break
	    }
	    update
	    tk_popup $m $x $y
	}
    }

    method textview {file} {
	set textviewer [dsk_editor fileview $textviewer $file]
    }

    method _adjust_menu {match label} {
	catch {$tkdesk_menu entryconfig $match -label $label}
    }

    proc setSoundEntryState {} {
	global tkdesk

	if ![info exists tkdesk(soundcmd)] {
	    foreach obj [itcl_info objects -class dsk_FileList] {
		set m $obj.fMenu.mbOthers.menu.opts
		$m entryconfig [$m index *Sound*] -state disabled
	    }
	    foreach obj [itcl_info objects -class dsk_FileViewer] {
		set m $obj.fMenu.mbOpts.menu
		$m entryconfig [$m index *Sound*] -state disabled
	    }
	} else {
	    foreach obj [itcl_info objects -class dsk_FileList] {
		set m $obj.fMenu.mbOthers.menu.opts
		$m entryconfig [$m index *Sound*] -state normal
	    }
	    foreach obj [itcl_info objects -class dsk_FileViewer] {
		set m $obj.fMenu.mbOpts.menu
		$m entryconfig [$m index *Sound*] -state normal
	    }
	}
    }

    proc adjustAppBarMenuEntry {displaying} {
	if $displaying {
	    set l "Hide AppBar"
	    set m "Display AppBar"
	} else {
	    set l "Display AppBar"
	    set m "Hide AppBar"
	}
	foreach fv [itcl_info objects -class dsk_FileViewer] {
	    if [winfo exists $fv] {
		$fv _adjust_menu $m $l
	    }
	}
	foreach fl [itcl_info objects -class dsk_FileList] {
	    if [winfo exists $fl] {
		$fl _adjust_menu $m $l
	    }
	}
    }

    #
    # ----- Variables ---------------------------------------------------------
    #

    protected textviewer ""
    protected tkdesk_menu
}

