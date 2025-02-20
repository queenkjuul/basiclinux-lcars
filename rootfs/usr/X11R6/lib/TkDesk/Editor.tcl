# =============================================================================
#
# File:		Editor.tcl
# Project:	TkDesk
#
# Started:	21.11.94
# Changed:	28.03.96
# Author:	cb
#
# Description:	Implements a class for multi-buffer editor windows plus
#               supporting procs.
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
#s    itcl_class dsk_Editor
#s    method config {config}
#s    method load {}
#s    method insertfile {}
#s    method save {{as ""} {auto 0} {id ""}}
#s    method print {}
#s    method buffer {cmd args}
#s    method _buffer_new {file}
#s    method _buffer_create {file {insert 0} {asknew 1}}
#s    method _load_default_cfg {}
#s    method _read_file {file}
#s    method _tkdesk {cmd}
#s    method _buffer_display {id}
#s    method _buffer_delete {id {dontdel 0}}
#s    method _buffer_reload {}
#s    method _changing {type data}
#s    method close_win {}
#s    method undo {}
#s    method copy {}
#s    method cut {}
#s    method paste {}
#s    method gotoline {}
#s    method search {}
#s    method _do_search {{exp ""}}
#s    method _do_replace {{mode "single"}}
#s    method textWidget {}
#s    method hypersearch {}
#s    method _hsearch_callback {line_nr}
#s    method _do_hsearch {}
#s    method findsel {}
#s    method setfont {{what ""}}
#s    method set_auto_indent {}
#s    method set_word_wrap {}
#s    method set_tab_string {{ask 1}}
#s    method _tabstr {}
#s    method _dd_drophandler {}
#s    method set_qmark {nr}
#s    method goto_qmark {nr}
#s    method popup {x y}
#s    proc id {{cmd ""}}
#s    proc bufferMenu {menu {win ""}}
#s    proc save_all {}
#s    proc dsk_editor {cmd args}
#s    proc dsk_editor_hsearch_cb {t exp}
#
# =============================================================================

#
# =============================================================================
#
# Class:	dsk_Editor
# Desc:		Implements a class for multi-buffer editor windows.
#
# Methods:	buffer create <file> - create a new buffer for $file
#               buffer delete <name> - delete buffer $name
#               buffer display <name> - switch to buffer $name
# Procs:	id - used internally to name objects of this class
# Publics:
#

itcl_class dsk_Editor {

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
	catch "rename $this-top {}"
        ::rename $this $this-top
        ::rename $this-tmp- $this

	frame $this.fMenu -bd 2 -relief raised
	pack $this.fMenu -fill x

	# ---- File Menu

	menubutton $this.fMenu.mbFile -text "File" -underline 0 \
		-menu $this.fMenu.mbFile.menu
 	pack $this.fMenu.mbFile -side left

	menu [set m $this.fMenu.mbFile.menu]
	$m add command -label "New  " -underline 0 \
		-command "$this buffer new {}"
	$m add command -label "Load...  " -underline 0 \
		-command "$this load"
	$m add command -label "Insert...  " -underline 0 \
		-command "$this insertfile"
	$m add command -label "Find...  " -underline 0 \
		-command "$this findfile"
	$m add command -label "Reload " -underline 0 \
		-command "$this buffer reload" -accelerator "Meta-r"
	$m add separator
	$m add command -label "Save " -underline 0 \
		-command "$this save" -accelerator "Meta-s"
	$m add command -label "Save as...  " -underline 5 \
		-command "$this save as"
	$m add command -label "Save all" -underline 2 \
		-command "dsk_Editor :: save_all"
	$m add command -label "Print... " -underline 0 \
		-command "$this print"
	$m add command -label "Mail to... " -underline 0 \
		-command "$this mail"
	$m add separator
	$m add command -label "Close Buffer " -underline 0 \
		-command "$this buffer delete *current*" -accelerator "Meta-c"
	$m add command -label "Close Window " -underline 6 \
		-command "$this close_win"
	$m add command -label "Close All " -underline 2 \
		-command "dsk_editor delall"

	# ---- Edit Menu
	
	menubutton $this.fMenu.mbEdit -text "Edit" -underline 0 \
		-menu $this.fMenu.mbEdit.menu
	pack $this.fMenu.mbEdit -side left

	menu [set m $this.fMenu.mbEdit.menu]
	$m add command -label "Undo" -underline 0 -command "$this undo" \
		-accelerator "Ctrl-z" -state disabled
	$m add separator
	$m add command -label "Cut" -underline 0 -command "$this cut" \
		-accelerator "Ctrl-x"
	$m add command -label "Copy" -underline 1 -command "$this copy" \
		-accelerator "Ctrl-c"
	$m add command -label "Paste" -underline 0 -command "$this paste" \
		-accelerator "Ctrl-v"
	$m add command -label "Select all" -underline 7 \
		-command "$this.ft.text tag add sel 1.0 end" \
		-accelerator "Ctrl-a"
	$m add separator
	$m add command -label "Search/Replace... " -underline 0 \
		-command "$this search" -accelerator "Ctrl-s"
	$m add command -label "HyperSearch... " -underline 0 \
		-command "$this hypersearch" -accelerator "Ctrl-h"
	$m add command -label "Find Selection" -underline 0 \
		-command "$this findsel" -accelerator "Meta-Spc"
	$m add separator
	$m add command -label "Goto Line... " -underline 0 \
		-command "$this gotoline" -accelerator "Ctrl-g"

	# ---- Options Menu

	menubutton $this.fMenu.mbOptions -text "Options" -underline 0 \
		-menu $this.fMenu.mbOptions.menu
	pack $this.fMenu.mbOptions -side left

	menu [set m $this.fMenu.mbOptions.menu]
	::set [set this](auto_indent) $tkdesk(editor,auto_indent)
	$m add checkbutton -label " Auto Indent" -underline 1 \
		-variable [set this](auto_indent) \
		-command "$this set_auto_indent"
	::set [set this](brace_indent) $tkdesk(editor,brace_indent)
	$m add checkbutton -label " Indent after  \"\{\"" -underline 1 \
		-variable [set this](brace_indent)
	$m add separator
	::set [set this](quick_load) 0
	$m add checkbutton -label " Quick Load" -underline 1 \
		-variable [set this](quick_load) \
		-command "$this set_quick_load"
	::set [set this](do_backups) $tkdesk(editor,do_backups)
	$m add checkbutton -label " Create Backups" -underline 1 \
		-variable [set this](do_backups)
	::set [set this](send_netscape) 0
	$m add checkbutton -label " Send to Netscape" -underline 9 \
		-variable [set this](send_netscape)
	$m add separator
	#$m add command -label "Font..." \
	#	 -underline 0 \
	#	 -command "$this setfont"
	#$m add command -label "Default Font  " \
	#	 -underline 0 \
	#	 -command "$this setfont default"

	$m add cascade -label "Tab Stops" -menu $m.mtab \
		-underline 0
	menu [set m $m.mtab]
	::set [set this](realtabs) $tkdesk(editor,real_tabs)
	$m add radiobutton -label "Real Tabs" \
		-underline 0 \
		-variable [set this](realtabs) \
		-value 1 \
		-command "$this set_tab_string"
	$m add radiobutton -label "Tab Width..." \
		-underline 0 \
		-variable [set this](realtabs) \
		-value 0 \
		-command "$this set_tab_string"
	
	set m $this.fMenu.mbOptions.menu
	$m add cascade -label "Line Wrap" -menu $m.mwrap \
		-underline 0
	menu [set m $m.mwrap]
	::set [set this](wrap) $tkdesk(editor,wrap)
	$m add radiobutton -label "None" \
		-underline 0 \
		-variable [set this](wrap) \
		-value none \
		-command "$this set_line_wrap"
	$m add radiobutton -label "Character" \
		-underline 0 \
		-variable [set this](wrap) \
		-value char \
		-command "$this set_line_wrap"
	$m add radiobutton -label "Word" \
		-underline 0 \
		-variable [set this](wrap) \
		-value word \
		-command "$this set_line_wrap"
	
	# ---- Buffer Menu

	menubutton $this.fMenu.mbBuffer -text "Buffers" -underline 0 \
		-menu $this.fMenu.mbBuffer.menu
	pack $this.fMenu.mbBuffer -side left

	menu $this.fMenu.mbBuffer.menu \
		-postcommand "dsk_Editor :: bufferMenu $this.fMenu.mbBuffer.menu $this"
	# add dummy entry to work around bug in pre Tk 4.0p2:
	$this.fMenu.mbBuffer.menu add command -label "dummy"
	
	tk_menuBar $this.fMenu $this.fMenu.mbFile $this.fMenu.mbEdit \
		$this.fMenu.mbOptions $this.fMenu.mbBuffer 
	tk_bindForTraversal $this

	# ---- Text Widget

	frame $this.f1 -bd 1 -relief raised
	pack $this.f1 -fill both -expand yes

	cb_text $this.ft -vscroll 1 -hscroll 0 \
		-pad $tkdesk(pad) -width 20 -height 5 \
		-bd 2 -relief sunken -lborder 1 -setgrid 1 \
		-wrap char -font [cb_font $tkdesk(editor,font)] \
		-exportselection 1 -bg [cb_col $tkdesk(color,text)] \
		-insertbackground [cb_col $tkdesk(color,insert)]
	pack $this.ft -in $this.f1 -fill both -expand yes -pady $tkdesk(pad)
	blt_drag&drop target $this.ft.text handler \
		file "$this _dd_drophandler"

	#
	# Bindings
	#
	bind $this <Any-Enter> {
	    if $tkdesk(focus_follows_mouse) {
		if {[grab current] == ""} {
		    focus [winfo toplevel %W].ft.text
		}
	    }
	}
	
	bind $this.ft.text <3> "$this popup %X %Y; break"
	bind $this.ft.text <Alt-s> "$this save; break"
	bind $this.ft.text <Meta-s> "$this save; break"
	bind $this.ft.text <Alt-c> "$this buffer delete *current*; break"
	bind $this.ft.text <Meta-c> "$this buffer delete *current*; break"
	bind $this.ft.text <Alt-r> "$this buffer reload; break"
	bind $this.ft.text <Meta-r> "$this buffer reload; break"
	bind $this.ft.text <Control-z> "$this undo; break"
	bind $this.ft.text <Control-c> "$this copy; break"
	bind $this.ft.text <Control-x> "$this cut; break"
	bind $this.ft.text <Control-v> "$this paste; break"
	bind $this.ft.text <Control-a> \
		"$this.ft.text tag add sel 1.0 end; break"
	bind $this.ft.text <Control-g> "$this gotoline; break"
	bind $this.ft.text <Alt-g> "$this gotoline; break"
	bind $this.ft.text <Meta-g> "$this gotoline; break"
	bind $this.ft.text <Control-s> "$this search; break"
	bind $this.ft.text <Control-h> "$this hypersearch; break"
	bind $this.ft.text <Alt-space> "$this findsel; break"
	bind $this.ft.text <Meta-space> "$this findsel; break"

	cb_manage_secondary $this $this-search

	for {set i 0} {$i < 10} {incr i} {
	    bind $this.ft.text <Control-Key-$i> "$this set_qmark $i"
	    bind $this.ft.text <Alt-Key-$i> "$this goto_qmark $i"
	    bind $this.ft.text <Meta-Key-$i> "$this goto_qmark $i"
	}
	
	global cb_Text
	set cb_Text(change_callback,$this.ft.text) "$this _changing"
	set_auto_indent
	set_line_wrap
	set_tab_string 0

	#
	# Window manager settings
	#
	wm minsize $this 20 5
	wm title $this "no file"
	regsub {[1-90][1-90]*x[1-90][1-90]*} \
		$tkdesk(editor,default_geometry) "" xy
	if {$xy != ""} {
	    wm geometry $this $tkdesk(editor,default_geometry)
	} else {
	    set w [lindex [split $tkdesk(editor,default_geometry) x+-] 0]
	    set h [lindex [split $tkdesk(editor,default_geometry) x+-] 1]
	    $this.ft.text config -width $w -height $h
	    dsk_place_window $this editor $tkdesk(editor,default_geometry) 1
	    $this.ft.text config -width 20 -height 5
	}
	wm protocol $this WM_DELETE_WINDOW "$this close_win"
	
	if $tkdesk(fvwm) {
	    # create the icon window
	    toplevel $this-icon -bg [cb_col $tkdesk(color,icon)] \
		    -class Icon
	    wm withdraw $this-icon
	    label $this-icon.label \
		    -image [dsk_image $tkdesk(icon,editor)] \
		    -bd 0 -bg [cb_col $tkdesk(color,icon)]
	    pack $this-icon.label -ipadx 2 -ipady 2
	    blt_drag&drop target $this-icon.label handler \
		    file "$this _dd_drophandler"
	    update idletasks
	    wm geometry $this-icon \
		    [winfo reqwidth $this-icon]x[winfo reqheight $this-icon]
	    wm protocol $this-icon WM_DELETE_WINDOW "$this delete"
	    wm iconwindow $this $this-icon
	} else {
	    wm iconbitmap $this @$tkdesk(library)/images/xbm/pencil3.xbm
	}

	# Other inits
	set current(buffer) ""
	::set [set this](case) 0
	::set [set this](regexp) 0

	# Populate HyperSearch history if still empty
	if {[hsearch_history get] == {}} {
	    # Linux HOWTO:
	    hsearch_history add {^  [1-9]\.}
	    # Tcl/itcl code:
	    hsearch_history add {^[ ]*proc|^[ ]*method|^[ ]*class|^[ ]*itcl_class|^[ ]*constructor|^[ ]*destructor}
	    # C/C++ functions:
	    hsearch_history add {^[a-zA-Z][a-zA-Z _1-90]*\(.*[\),]$}
	}

	eval config $args
	cb_deiconify $this
	update
    }

    destructor {
	global [set this]

	catch {::unset [set this]}
        #after 10 rename $this-top {}	;# delete this name
        catch {destroy $this}	;# destroy associated windows
	catch {destroy ${this}-icon}
	catch {destroy ${this}-search}
	catch {destroy ${this}-hsearch}
    }

    #
    # ----- Methods and Procs -------------------------------------------------
    #

    method config {config} {
    }

    method load {} {
	global tkdesk

	set curfile $buffer($currentid,file)
	if {[string match "New *" $curfile] || \
		[string first " " $curfile] > -1} {
	    set filter [dsk_active dir]*
	} else {
	    if [file readable [file dirname $curfile]] {
		set filter [string trimright [file dirname $curfile] "/"]/*
	    } else {
		set filter [dsk_active dir]*
	    }
	}

	while {1} {
	    set file [dsk_filesel "Select a file to edit:" $filter showall]
	    
	    if {$file != ""} {
		if [file isdirectory $file] {
		    dsk_errbell
		    cb_error "$file is a directory. Please choose a file."
		} else {
		    $this buffer create $file
		    break
		}
	    } else {
		break
	    }
	}
    }

    method insertfile {} {
	set curfile $buffer($currentid,file)
	if {[string match "New *" $curfile] || \
		[string first " " $curfile] > -1} {
	    set filter [dsk_active dir]*
	} else {
	    if [file readable [file dirname $curfile]] {
		set filter [string trimright [file dirname $curfile] "/"]/*
	    } else {
		set filter [dsk_active dir]*
	    }
	}
	#set file [cb_fileSelector -filter $filter \
		#-label "Select file to insert:" -showall 1]
	while {1} {
	    set file [dsk_filesel "Select a file to insert:" $filter showall]
	    
	    if {$file != ""} {
		if [file isdirectory $file] {
		    dsk_errbell
		    cb_error "$file is a directory. Please choose a file."
		} else {
		    $this buffer create $file 1
		    break
		}
	    } else {
		break
	    }
	}
    }

    method findfile {} {
	global tkdesk

	set curfile [cb_tilde $buffer($currentid,file) expand]
	dsk_find_files -path [file dirname $curfile] \
		-mask *[file extension $curfile]
    }
    
    method save {{as ""} {auto 0} {id ""}} {
	global tkdesk [set this]

	if {$id == ""} {
	    set id $currentid
	}
	set curfile $buffer($id,file)
	if {[string match "New *" $curfile] || \
		[string match "* (Output)" $curfile]} {
	    set filter [dsk_active dir]*
	} else {
	    if [file readable [file dirname $curfile]] {
		set filter [string trimright [file dirname $curfile] "/"]/*
	    } else {
		set filter [dsk_active dir]*
	    }
	}

	set file $buffer($id,file)
	set old_fname $buffer($id,file)
	set old_auto_fname [file dirname $file]/\#[file tail $file]\#
	if {$as != "" \
		|| [string match "New *" $buffer($id,file)] \
		|| [string match "* (Output)" $curfile] \
		|| $buffer($id,readonly)} {
	    if $auto {
		return "ok"
	    }
	    #set fname [cb_fileSelector -filter $filter \
		    #-label "Save file as:" -showall 1]
	    set fname [dsk_filesel "Save file as:" $filter showall]
	    if {$fname == ""} {
		return "cancel"
	    } else {
		set buffer($id,file) $fname
		set file $fname
	    }
	}
	
	if $auto {
	    if [set [set this](do_backups)] {
		set file [file dirname $file]/\#[file tail $file]\#
	    }
	} else {
	    # make a backup copy of the file
	    if {[info exists file] && [set [set this](do_backups)]} {
		catch {exec cp $file $file~}
	    }
	}

	set ext [file extension $file]
	if {$ext == ".gz" || $ext == ".z"} {
	    set err [catch  {set fd [open "|gzip >\"$file\"" w]}]
	} elseif {$ext == ".Z"} {
	    set err [catch  {set fd [open "|compress >\"$file\"" w]}]
	} else {
	    set err [catch {set fd [open "$file" w]}]
	}
	if $err {
	    dsk_errbell
	    cb_error "Couldn't open $file for writing!"
	    set buffer($id,file) $old_fname
	    return "cancel"
	}
	dsk_busy
	dsk_catch {
	    puts -nonewline $fd [$this.ft.text get 1.0 "end - 1 chars"]
	    close $fd
	}

	if !$auto {
	    set changed($id) 0
	    set buffer($id,readonly) 0
	    set buffer($id,newfile) 0
	    set file [subst -nocommands $file]
	    if {$id == $currentid} {
		wm title $this "[cb_tilde $file collapse]"
		wm iconname $this "[file tail $file]"
	    }
	    
	    # remove a previous auto-save copy:
	    if [file exists $old_auto_fname] {
		catch {exec rm $old_auto_fname}
	    }
	    
	    if [set [set this](send_netscape)] {
		dsk_netscape file [cb_tilde $file expand]
	    }
	}
	$this.ft.text config -state normal
	dsk_lazy
	return "ok"
    }

    method print {} {
	global tkdesk tmppcmd

	dsk_print_string [$this.ft.text get 1.0 end]
    }
	
    method mail {} {
	global tkdesk tmppcmd

	dsk_mail "" [$this.ft.text get 1.0 end]
    }
	
    method buffer {cmd args} {
	switch -- $cmd {
	    new {return [eval _buffer_new $args]}
	    create {return [eval _buffer_create $args]}
	    delete {return [eval _buffer_delete $args]}
	    display {return [eval _buffer_display $args]}
	    reload {return [eval _buffer_reload $args]}	    
	}
    }

    method _buffer_new {file} {
	if {$file == ""} {
	    set file "New File"
	}
	set id [incr bufcount]
	set buffer($id,file) $file
	set buffer($id,text) ""
	set buffer($id,vpos) 0
	set buffer($id,cursor) 1.0
	set buffer($id,win) $this
	set buffer($id,newfile) 1
	if ![file writable [file dirname $file]] {
	    set buffer($id,readonly) 1
	} else {
	    set buffer($id,readonly) 0
	}
	set changed($id) 0
	set undo_enabled($id) 0
	set undo_list($id) ""
	set undo_pointer($id) -1
	$this buffer display $id
	return $id
    }
	
    
    method _buffer_create {file {insert 0} {asknew 1}} {
	global tkdesk

	catch {
	    if [winfo exists tkdesk(_ed_browser)] {
		$tkdesk(_ed_browser) close
	    }
	}

	set id ""
	if ![file exists $file] {
	    if !$insert {
		set id [$this buffer new $file]
	    } else {
		cb_error "$file does not exist."
	    }
	} else {
	    if [file isdirectory $file] {
		dsk_errbell
		cb_error "Please use TkDesk's file windows to edit directories! ;-)"
		#catch "$this delete"
		return -1
		
	    }

	    # see if this file is already loaded
	    #for {set id 1} {$id <= $bufcount} {incr id} {
	    #	 if ![info exists buffer($id,file)] continue
	    #	 if {$buffer($id,file) == $file} {
	    #	     $buffer($id,win) buffer display $id
	    #	     return
	    #	 }
	    #}
	    
	    if {[file size $file] > 500000} {
		if {[cb_okcancel "You're about to load a very large file into the editor. This will probably take ages and require a ridiculous amount of memory. Continue anyway?"] == 1} {
		    if !$insert {
			catch "$this delete"
		    }
		    return -1
		}
	    }
	    set ext [file extension $file]
	    if {$ext == ".gz" || $ext == ".z"} {
	        set err [catch  {set fd [open "|gzip -cd \"$file\""]}]
	    } elseif {$ext == ".Z"} {
	        set err [catch  {set fd [open "|zcat \"$file\""]}]
	    } else {
	        set err [catch {set fd [open $file]}]
	    }
	    if $err {
		dsk_errbell
		catch "cb_error \"Error: Couldn't open $file for reading!\""
		if !$insert {
		    catch "$this delete"
		}
		return -1
	    }
	    set err [dsk_catch {
		dsk_busy
		if !$insert {
		    set id [incr bufcount]
		    set buffer($id,file) $file
		    set buffer($id,text) [read $fd]
		    set buffer($id,vpos) 0
		    set buffer($id,cursor) 1.0
		    set buffer($id,win) $this
		    set buffer($id,newfile) 0
		    set changed($id) 0
		    set undo_enabled($id) 0
		    set undo_list($id) ""
		    set undo_pointer($id) -1
		    
		    if ![file writable $file] {
			#cb_alert "Opening file read-only."
			set buffer($id,readonly) 1
		    } else {
			set buffer($id,readonly) 0
		    }
		} else {
		    $this.ft.text insert insert [read $fd]
		    cb_Text_change_callback $this.ft.text
		}
		close $fd
		dsk_lazy
	    }]
	    if $err {
		if !$insert {
		    catch "$this delete"
		}
		return -1
	    }
	    if $insert {
		return
	    }
	    $this buffer display $id
	}
	if {[string first $tkdesk(configdir) $file] == 0} {
	    if ![winfo exists $this.fMenu.mbTkDesk] {
		menubutton $this.fMenu.mbTkDesk -text "TkDesk" \
			-menu [set m $this.fMenu.mbTkDesk.m] \
			-underline 0
		pack propagate $this.fMenu 0
		pack $this.fMenu.mbTkDesk -side left
		
		menu $m
		$m add command -label "Save and Reload into TkDesk " \
			-command "$this _tkdesk reload" \
			-accelerator F5
		$m add command -label "Save, Reload and Close" \
			-command "$this _tkdesk reload_and_close" \
			-accelerator F6
		$m add command -label "Evaluate Selection" \
			-command {dsk_catch {eval [selection get]}} \
			-accelerator F7
		$m add command -label "Load Default Version" \
			-command "$this _load_default_cfg" \
			-accelerator F8
		$m add separator
		$m add command -label "Colors..." \
			-command "dsk_config_panel colors $this.ft.text" \
			-accelerator F9
		$m add command -label "Fonts..." \
			-command "dsk_config_panel fonts $this.ft.text" \
			-accelerator F10
		$m add command -label "Icons..." \
			-command "dsk_config_panel icons $this.ft.text" \
			-accelerator F11
		$m add command -label "Sounds..." \
			-command "dsk_config_panel sounds $this.ft.text" \
			-accelerator F12
		bind $this.ft.text <F5> "$this _tkdesk reload"
		bind $this.ft.text <F6> "$this _tkdesk reload_and_close"
		bind $this.ft.text <F7> {dsk_catch {eval [selection get]}}
		bind $this.ft.text <F8> "$this _load_default_cfg"
		bind $this.ft.text <F9> \
			"dsk_config_panel colors $this.ft.text"
		bind $this.ft.text <F10> \
			"dsk_config_panel fonts $this.ft.text"
		bind $this.ft.text <F11> \
			"dsk_config_panel icons $this.ft.text"
		bind $this.ft.text <F12> \
			"dsk_config_panel sounds $this.ft.text"
	    }
	}
	return $id
    }

    method _load_default_cfg {} {
	global tkdesk
	
	set f $tkdesk(library)/configs/[file tail $buffer($currentid,file)]
	buffer create $f
    }

    method _read_file {file} {
    }

    method _tkdesk {cmd} {
	global tkdesk
	
	set id $currentid
	set curfile $buffer($currentid,file)
	if {[string first $tkdesk(configdir) $curfile] < 0} {
	    dsk_errbell
	    cb_error "This is not one of TkDesk's current configuration files!"
	    return
	}
	
	switch -- $cmd {
	    "reload" {
		save
		dsk_reread_config [file tail $curfile]
	    }
	    "reload_and_close" {
		save
		buffer delete *current*
		dsk_reread_config [file tail $curfile]
	    }
	}
    }

    method _buffer_display {id} {
	global tkdesk [set this]

	if $dont_display return
	
	if {$currentid != -1} {
	    set buffer($currentid,vpos) [lindex \
		    [cb_old_sb_get $this.ft.vscroll] 2]
	    set buffer($currentid,cursor) [$this.ft.text index insert]
	    set buffer($currentid,text) [$this.ft.text get 1.0 "end - 1 chars"]
	}
	$this.ft.text config -state normal
	$this.ft.text delete 1.0 end
	$this.ft.text insert end $buffer($id,text)
	$this.ft.text yview $buffer($id,vpos)
	$this.ft.text mark set insert $buffer($id,cursor)
	if $buffer($id,readonly) {
	    $this.ft.text config -bg [cb_col $tkdesk(color,background)]
	} else {
	    $this.ft.text config -bg [cb_col $tkdesk(color,text)]
	}
	if {[wm state $this] != "normal"} {
	    cb_deiconify $this
	} else {
	    raise $this
	}
	set currentid $id
	set name $buffer($id,file)
	if $changed($id) {
	    set t "* [cb_tilde $name collapse]"
	    if {$buffer($id,newfile) && $name != "New File"} {
		append t " (new)"
	    }
	    if {$buffer($id,readonly)} {
		append t " (read-only)"
	    }
	    wm title $this $t
	    wm iconname $this "*[file tail $name]"
	} else {
	    set t [cb_tilde $name collapse]
	    if {$buffer($id,newfile) && $name != "New File"} {
		append t " (new)"
	    }
	    if {$buffer($id,readonly)} {
		append t " (read-only)"
	    }
	    wm title $this $t
	    wm iconname $this [file tail $name]
	}
	if [info exists tkdesk(editor,findexp)] {
	    if {$tkdesk(editor,findexp) != ""} {
		set [set this](regexp) $tkdesk(editor,findisreg)
		_do_search $tkdesk(editor,findexp)
	    }
	}
    }

    method _buffer_delete {id {dontdel 0}} {
	if {$id == "*current*"} {
	    set id $currentid
	}

	if ![info exists changed($id)] return
	if $changed($id) {
	    if {$currentid != $id} {
		set dd $dont_display
		set dont_display 0
		$this buffer display $id
		set dont_display $dd
	    }

	    cb_raise $this
	    catch {destroy $this.tqmod}
	    set ans [cb_dialog $this.tqmod "File modified" \
		    "[file tail $buffer($id,file)]:\nThis file has been modified. Save it?" \
		    questhead 0 "Yes" "No" "Cancel"]
	    if {$ans == 0} {
		set ret [save]
		if {$ret == "cancel"} {
		    return "cancel"
		}
	    } elseif {$ans == 2} {
		return "cancel"
	    }
	}

	dsk_busy
	
	# remove auto save copy:
	if ![info exists buffer($id,file)] return
	set file $buffer($id,file)
	set file [file dirname $file]/\#[file tail $file]\#
	if [file exists $file] {
	    catch {exec rm -f $file}
	}

	if !$dont_display {
	    $this.ft.text delete 1.0 end
	}
	set currentid -1
	unset buffer($id,file)
	unset buffer($id,text)
	unset buffer($id,vpos)
	unset buffer($id,cursor)
	unset buffer($id,win)
	unset changed($id)
	unset undo_enabled($id)
	unset undo_list($id)
	unset undo_pointer($id)

	# delete quickmarks associated with this buffer
	for {set nr 0} {$nr < 10} {incr nr} {
	    if {[lindex $qmark($nr) 0] == $id} {
		set qmark($nr) ""
	    }
	}

	set id -1
	for {set i 1} {$i <= $bufcount} {incr i} {
	    if [info exists buffer($i,file)] {
		if [info exists buffer($i,win)] {
		    if {$buffer($i,win) == $this} {
			set id $i
			break
		    }
		} else {
		    unset buffer($i,file)
		}
	    }
	}
	
	dsk_lazy
	
	if {$id != -1} {
	    $this buffer display $id
	    return ""
	} else {
	    if !$dontdel {
		$this delete
	    }
	}
    }

    method _buffer_reload {} {
	
	set id $currentid

	if $changed($id) {
	    if {$currentid != $id} {
		$this buffer display $id
	    }
	    cb_raise $this
	    catch {destroy $this.tqmod}
	    set ans [cb_dialog $this.tqmod "File modified" \
		    "This file has been modified. Save it?" \
		    questhead 0 "Yes" "No" "Cancel"]
	    if {$ans == 0} {
		save
	    } elseif {$ans == 2} {
		return "cancel"
	    }
	}
	set file $buffer($id,file)
	set ext [file extension $file]
	if {$ext == ".gz" || $ext == ".z"} {
	    set err [catch  {set fd [open "|gzip -cd \"$file\""]}]
	} elseif {$ext == ".Z"} {
	    set err [catch {set fd [open "|zcat \"$file\""]}]
	} else {
	    set err [catch {set fd [open $file]}]
	}
	if $err {
	    dsk_errbell
	    cb_error "Error: Couldn't open $file for reading!"
	    return
	}
	dsk_busy
	dsk_catch {
	    set buffer($id,text) [read $fd]
	    set changed($id) 0
	    close $fd
	}
	wm title $this [cb_tilde $file collapse]
	wm iconname $this "[file tail $file]"
	dsk_lazy
	set buffer($id,vpos) [lindex [cb_old_sb_get $this.ft.vscroll] 2]
	set buffer($id,cursor) [$this.ft.text index insert]
	$this.ft.text delete 1.0 end
	$this.ft.text insert end $buffer($id,text)
	$this.ft.text yview $buffer($id,vpos)
	$this.ft.text mark set insert $buffer($id,cursor)
    }	

    method _changing {type data} {

	if {$currentid < 0} return
	#puts "(_changing) type: $type, data: $data"
	
	if !$changed($currentid) {
	    set changed($currentid) 1
	    set file $buffer($currentid,file)
	    wm title $this "* [cb_tilde $file collapse]"
	    wm iconname $this "*[file tail $file]"
	}
	incr autosavecount
	if {$autosavecount >= $autosaveperiod} {
	    set autosavecount 0
	    save "" 1
	}

	# prepare for undo
	if !$undo_enabled($currentid) {
	    set undo_enabled($currentid) 1
	    $this.fMenu.mbEdit.menu entryconfigure "Undo" -state normal
	}
	set ip [$this.ft.text index insert]
	set selr [$this.ft.text tag ranges sel]
	if {$selr != ""} {
	    set ip [lindex $selr 0]
	}
	set ule ""
	switch -- $type {
	    insert {
		if {$selr != ""} {
		    set selb [eval $this.ft.text get $selr]
		    set utype replace
		} else {
		    set selb {}
		    set utype add
		}
		set ule [list $ip $utype $data $selb]
	    }
	    paste {
		set x [lindex $data 0]
		set y [lindex $data 1]
		if {[::info proc tkTextClosestGap] != ""} {
		    set ip [tkTextClosestGap $this.ft.text $x $y]
		} else {
		    set ip [$this.ft.text index @$x,$y]
		}
		set data [lindex $data 2]
		set selb {}
		set utype add
		set ule [list $ip $utype $data $selb]
	    }
	    replace {
		# called from _do_replace
		ot_maplist $data start end text
		set ule [list $start replace $text \
			[$this.ft.text get $start $end]]
	    }
	    delete {
		switch -- $data {
		    backchar -
		    char {
			if {$selr != ""} {
			    set selb [eval $this.ft.text get $selr]
			    set data {}
			} else {
			    if {$data == "char"} {
				set selb {}
				set data [$this.ft.text get insert]
			    } else {
				set selb {}
				set data [$this.ft.text get "insert - 1 chars"]
				set ip [$this.ft.text index "$ip - 1 chars"]
			    }
			}
			set ule [list $ip remove $data $selb]
		    }
		    word {
			set ule [list $ip remove \
			      [$this.ft.text get insert "insert wordend"] {}] 
		    }
		    lineend {
			set ule [list $ip remove \
			      [$this.ft.text get insert "insert lineend"] {}] 
		    }
		}
	    }
	}
	if {$ule != ""} {
	    incr undo_pointer($currentid)
	    catch {
		set undo_list($currentid) \
			[lreplace $undo_list($currentid) \
			 $undo_pointer($currentid) 10000]
	    }
	    if {$undo_pointer($currentid) > $undo_size} {
		# prevent the undo list from growing infinitely
		set undo_list($currentid) \
			[lreplace $undo_list($currentid) 0 \
			[expr $undo_pointer($currentid) \
			 - $undo_size]]
	    }
	    lappend undo_list($currentid) $ule
	}
	#set undo_pointer [expr [llength $undo_list($currentid)] - 1]
    }

    method close_win {} {
	set ret ""
	set dont_display 1
	for {set id 1} {$id <= $bufcount} {incr id} {
	    if [info exists buffer($id,file)] {
		catch {
		    if {$buffer($id,win) == $this} {
			if {[$this buffer delete $id] == "cancel"} {
			    set ret cancel
			}
		    }
		}
	    }
	    if {$ret == "cancel"} break
	}
	set dont_display 0
	return $ret
    }

    method undo {} {
	if $undo_enabled($currentid) {
	    if {$undo_pointer($currentid) < 0} {
		dsk_bell
		return
	    }
	    if {$undo_pointer($currentid) \
		    >= [llength $undo_list($currentid)]} {
		# just to be safe...
		set undo_pointer($currentid) \
			[expr [llength $undo_list($currentid)] - 1]
	    }
	    set ul [lindex $undo_list($currentid) $undo_pointer($currentid)]
	    #puts $ul
	    incr undo_pointer($currentid) -1
	    if {$undo_pointer($currentid) < 0} {
		set undo_enabled($currentid) 0
		$this.fMenu.mbEdit.menu entryconfigure "Undo" -state disabled
		set changed($currentid) 0
		set file $buffer($currentid,file)
		wm title $this "[cb_tilde $file collapse]"
		wm iconname $this "[file tail $file]"
	    }
	    ot_maplist $ul inspos type data sel
	    switch -- $type {
		replace -
		add {
		    switch -- $data {
			<tab> -
			<return> {
			    $this.ft.text delete $inspos
			}
			default {
			    $this.ft.text delete $inspos \
				    [$this.ft.text index \
				    "$inspos + [string length $data] chars"]
			}
		    }
		    if {$type == "replace"} {
			$this.ft.text insert $inspos $sel
			$this.ft.text mark set insert \
				"$inspos + [string length $sel] chars"
		    } else {
			$this.ft.text mark set insert $inspos
		    }
		}
		remove {
		    if {$data != ""} {
			$this.ft.text insert $inspos $data
			$this.ft.text mark set insert \
				"$inspos + [string length $data] chars"
		    } else {
			$this.ft.text insert $inspos $sel
			$this.ft.text mark set insert \
				"$inspos + [string length $sel] chars"
		    }
		}
	    }
	    $this.ft.text see $inspos
	    if {$undo_pointer($currentid) >= 0 && !$changed($currentid)} {
		set changed($currentid) 1
		set file $buffer($currentid,file)
		wm title $this "* [cb_tilde $file collapse]"
		wm iconname $this "*[file tail $file]"
		incr autosavecount
	    }
	} else {
	    dsk_bell
	}
    }

    method copy {} {
	global cb_Text
	
	set sel [$this.ft.text tag ranges sel]
	if {$sel != ""} {
	    set cutbuffer [eval $this.ft.text get $sel]
	    selection clear $this.ft.text
	    catch "unset cb_Text(selstart)"
	}
    }

    method cut {} {
	global cb_Text

	set sel [$this.ft.text tag ranges sel]
	if {$sel != ""} {
	    cb_Text_change_callback $this.ft.text delete char
	    set cutbuffer [eval $this.ft.text get $sel]
	    eval $this.ft.text delete $sel
	    selection clear $this.ft.text
	    catch "unset cb_Text(selstart)"
	}
    }

    method paste {} {
	global cb_Text

	if {[string length "$cutbuffer"] > 0} {
	    set t $this.ft.text
	    set bb [$t bbox [$t index insert]]
	    $t insert insert $cutbuffer
	    $t yview -pickplace insert
	    cb_Text_change_callback $this.ft.text paste [list \
		    [lindex $bb 0] [lindex $bb 1] $cutbuffer]
	    selection clear $this.ft.text
	    catch "unset cb_Text(selstart)"
	} else {
	    dsk_bell
	}
    }

    method gotoline {} {
	global tmplnr
	
	set curline [lindex [split [$this.ft.text index insert] "."] 0]
	set tmplnr ""
	cb_readString "Goto line (current: $curline):" tmplnr "Goto Line" 10
	if {$tmplnr != ""} {
	    # test if $tmplnr contains a number:
	    set err [catch {$this.ft.text mark set insert $tmplnr.0}]
	    if !$err {
		$this.ft.text yview -pickplace insert
	    } else {
		dsk_errbell
		cb_error "Invalid line number!"
	    }
	}
	unset tmplnr
    }

    method search {} {
	global tkdesk [set this]
	
	set t "$this-search"
	if [winfo exists $t] {
	    cb_raise $t
	    focus $t.es
	    return
	}

	toplevel $t
	wm withdraw $t
	
	frame $t.fs -bd 1 -relief raised
	pack $t.fs -fill both -expand yes
	frame $t.fsf
	pack $t.fsf -in $t.fs -fill both -expand yes \
		-padx $tkdesk(pad) -pady $tkdesk(pad)
	frame $t.fslf
	pack $t.fslf -in $t.fsf -fill x
	label $t.ls -text "Search for:" -anchor w
	pack $t.ls -in $t.fslf -side left
	checkbutton $t.cbRegexp -text "Regular Expr." -relief flat \
		-variable [set this](regexp)
	pack $t.cbRegexp -in $t.fslf -side right
	checkbutton $t.cbCase -text "Case Sensitive " -relief flat \
		-variable [set this](case)
	pack $t.cbCase -in $t.fslf -side right
	
	frame $t.fsfe
	entry $t.es -bd 2 -relief sunken -width 40
	$t.es insert end $searchexp
	pack $t.es -in $t.fsfe -fill x -expand yes \
		-side left -ipady 2 -pady $tkdesk(pad)

	menubutton $t.mbSHist -bd 2 -relief raised \
		-bitmap @$tkdesk(library)/cb_tools/bitmaps/combo.xbm \
		-menu $t.mbSHist.menu
	pack $t.mbSHist -in $t.fsfe -side right \
		-padx $tkdesk(pad) -pady $tkdesk(pad) -ipadx 2 -ipady 2
	
	menu $t.mbSHist.menu -postcommand "$this _histmenu search_history $t.mbSHist.menu $t.es"
	# add dummy entry to work around bug in pre Tk 4.0p2:
	$t.mbSHist.menu add command -label "dummy"
	search_history changed
	
	pack $t.fsfe -in $t.fsf -fill x -expand yes
	
	bind $t.es <1> \
		"focus %W ;\
		$t.bReplace config -relief flat ;\
		$t.bSearch config -relief sunken"
	bind $t.es <Tab> \
		"$this _do_search ;\
		focus $t.er ;\
		$t.bSearch config -relief flat ;\
		$t.bReplace config -relief sunken"
	bind $t.es <Escape> "destroy $t"
	bind $t.es <Return> "$this _do_search"
	bind $t.es <Control-s> "$this _do_search"

	frame $t.fr -bd 1 -relief raised
	pack $t.fr -fill both -expand yes
	frame $t.frf
	pack $t.frf -in $t.fr -fill both -expand yes \
		-padx $tkdesk(pad) -pady $tkdesk(pad)
	label $t.lr -text "Replace with:" -anchor w
	pack $t.lr -in $t.frf -anchor w

	frame $t.frfr
	entry $t.er -bd 2 -relief sunken -width 40
	pack $t.er -in $t.frfr -side left \
		-fill x -expand yes -ipady 2 -pady $tkdesk(pad)

	menubutton $t.mbRHist -bd 2 -relief raised \
		-bitmap @$tkdesk(library)/cb_tools/bitmaps/combo.xbm \
		-menu $t.mbRHist.menu
	pack $t.mbRHist -in $t.frfr -side right \
		-padx $tkdesk(pad) -pady $tkdesk(pad) -ipadx 2 -ipady 2
	
	menu $t.mbRHist.menu -postcommand "$this _histmenu replace_history $t.mbRHist.menu $t.er"
	# add dummy entry to work around bug in pre Tk 4.0p2:
	$t.mbRHist.menu add command -label "dummy"
	replace_history changed
	
	pack $t.frfr -in $t.frf -fill x -expand yes
	
	bind $t.er <1> \
		"$this _do_search ;\
		focus %W ;\
		$t.bSearch config -relief flat ;\
		$t.bReplace config -relief sunken"
	bind $t.er <Tab> \
		"focus $t.es ;\
		$t.bReplace config -relief flat ;\
		$t.bSearch config -relief sunken"
	bind $t.er <Escape> "destroy $t; focus -force $this"
	bind $t.er <Return> "$this _do_replace"

	frame $t.fb -bd 1 -relief raised
	pack $t.fb -fill x
	cb_button $t.bSearch -text  "Search" -default 1 \
		-command "$this _do_search"
	cb_button $t.bReplace -text "Replace" \
		-command "$this _do_replace"
	cb_button $t.bRepAll -text "Replace all" \
		-command "$this _do_replace all"
	cb_button $t.bClose -text " Close " -command "destroy $t; focus -force $this"
	pack $t.bSearch $t.bReplace $t.bRepAll $t.bClose \
		-in $t.fb -side left \
		-padx $tkdesk(pad) -pady $tkdesk(pad)

	bind $t <Any-Enter> \
		"if \$tkdesk(focus_follows_mouse) \{ \
		if \{\[focus\] != \"$t.er\"\} \{
		focus $t.es
		$t.bReplace config -relief flat
		$t.bSearch config -relief sunken
		\}
		\}"
	
	
	wm title $t "Search/Replace"
	wm minsize $t 311 170
	update idletasks

	# determine position of search window:
	set rw [winfo reqwidth $t]
	set rh [winfo reqheight $t]
	set ww [winfo width $this]
	set wh [winfo height $this]
	set sw [winfo screenwidth $t]
	set sh [winfo screenheight $t]
	set wx [winfo x $this]
	set wy [winfo y $this]
	set dy 34 ;# offset for window decoration
	set x $wx
	if {$x < 0} {set x 0}
	if {$x + $rw > $sw} {set x [expr $sw - $rw]}
	set h1 $wy
	set h2 [expr $sh - $wy - $wh]
	if {$h1 > $h2} {
	    set y [expr $wy - $rh]
	    if {$y < 0} {set y 0}
	} else {
	    set y [expr $wy + $wh]
	    if {$y + $rh + $dy > $sh} {
		set y [expr $sh - $rh - $dy]
	    }
	}
	#puts "$wx $wy $ww $wh, $rw $rh, $h1 $h2, $x $y"
	wm geometry $t +$x+$y
	cb_deiconify $t

	focus $t.es
    }

    method _histmenu {histobj menu entry} {
	global tkdesk

	catch {$menu delete 0 last}
	if $tkdesk(sort_history) {
	    set l [lsort [$histobj get]]
	} else {
	    set l [$histobj get]
	}
	foreach ent $l {
	    $menu add command -label $ent \
		    -command "$entry delete 0 end ;\
		    $entry insert end \[list $ent\]" \
		    -font [cb_font $tkdesk(font,entries)]
	}
    }
    
    method _do_search {{exp ""}} {
	global [set this]

	if {$exp == ""} {
	    set exp [$this-search.es get]
	}
	if {$exp == ""} return
	set searchexp $exp
	search_history add [list $exp]

	set match_range ""
	set tw $this.ft.text
	catch "$tw tag remove sel 1.0 end"
	dsk_busy
	set stidx "insert"
	set success 0
	set scmd "$tw search -count cnt"
	if ![set [set this](case)] {
	    append scmd " -nocase"
	}
	if [set [set this](regexp)] {
	    append scmd " -regexp"
	}
	set scmd1 $scmd
	append scmd " -- [list $exp] insert end"
	set err [catch {set mrange [eval $scmd]}]
	if {$err && [set [set this](regexp)]} {
	    dsk_lazy
	    dsk_errbell
	    cb_error "Error in regular expression."
	    return
	}
	if {$mrange != ""} {
	    set success 1
	    lappend mrange [$tw index "$mrange + $cnt chars"]
	}
       	dsk_lazy
	if !$success {
	    set restart ![cb_yesno "No more matches. Restart at top?"]
	    if $restart {
		dsk_busy
		set stidx "1.0"
		set success 0
		set scmd $scmd1
		append scmd " -- $exp 1.0 end"
		set err [catch {set mrange [eval $scmd]} errmsg]
		if {$err && [set [set this](regexp)]} {
		    dsk_lazy
		    dsk_errbell
		    cb_error "Error in regular expression."
		    return
		}
		if {$mrange != ""} {
		    set success 1
		    lappend mrange [$tw index "$mrange + $cnt chars"]
		}
		dsk_lazy
	    } else {
		return
	    }
	}
	if $success {
	    set mstart [lindex $mrange 0]
	    set mend [lindex $mrange 1]
	    set match_range $mrange
	    $tw tag add sel $mstart $mend
	    $tw yview -pickplace $mstart
	    $tw mark set insert $mend
	    set search_regexp $exp
	} else {
	    dsk_bell
	}
    }

    method _do_replace {{mode "single"}} {
	global [set this] cb_Text
	
	if {$match_range == ""} {
	    $this _do_search
	}
	if {$match_range == ""} return	
	set mstart [lindex $match_range 0]
	if {$mode == "single"} {
	    set mend [lindex $match_range 1]
	} else {
	    set mend end
	}
	set subexp [$this-search.er get]
	#if {$subexp == ""} return
	replace_history add [list $subexp]

	dsk_busy
	set exp $search_regexp
	if ![set [set this](regexp)] {
	    set exp [dskC_esc $exp {|*+?.^$[]-()}]
	}
	set tw $this.ft.text
	set otext [$tw get $mstart $mend]
	if ![set [set this](case)] {
	    if {$mode == "single"} {
		set err [catch {regsub -nocase -- \
			$exp $otext $subexp stext} errmsg]
	    } else {
		set err [catch {regsub -nocase -all -- \
			$exp $otext $subexp stext} errmsg]
	    }
	} else {
	    if {$mode == "single"} {
		set err [catch {regsub -- \
			$exp $otext $subexp stext} errmsg]
	    } else {
		set err [catch {regsub -all -- \
			$exp $otext $subexp stext} errmsg]
	    }
	}
	
	if {$err && [set [set this](regexp)]} {
	    dsk_lazy
	    dsk_errbell
	    cb_error "Error in regular expression."
	    return
	}
	cb_Text_change_callback $tw replace "$mstart $mend [list $stext]"
	$tw delete $mstart $mend
	$tw insert $mstart $stext
	selection clear $tw
	catch "unset cb_Text(selstart)"
	dsk_lazy

	if {$mode == "single"} {
	    $this _do_search
	}
    }

    # ----------------------
    # textWidget:
    # Returns name of the embedded text widget.
    #
    method textWidget {} {
	return $this.ft.text
    }

    # ----------------------
    # hypersearch:
    # Creates a toplevel to enter a regular expression. Than grep is run on
    # the current buffer and the listbox is filled with matching lines.
    # Pressing MB 1 on one listbox entry makes the respective line the first
    # visible in the buffer.
    #
    method hypersearch {} {
	global tkdesk [set this]
	
	set t "$this-hsearch"
	if [winfo exists $t] {
	    cb_raise $t
	    return
	}

	toplevel $t
	wm withdraw $t
	
	frame $t.fs -bd 1 -relief raised
	pack $t.fs -fill x
	frame $t.fsf
	pack $t.fsf -in $t.fs -fill x \
		-padx $tkdesk(pad) -pady $tkdesk(pad)
	frame $t.fslf
	pack $t.fslf -in $t.fsf -fill x
	label $t.ls -text "Search for (regexp):" -anchor w
	pack $t.ls -in $t.fslf -side left
	checkbutton $t.cbCase -text "Case Sensitive" -relief flat \
		-variable [set this](case)
	pack $t.cbCase -in $t.fslf -side right
	checkbutton $t.cbSort -text "Sort    " -relief flat \
		-variable [set this](sort)
	pack $t.cbSort -in $t.fslf -side right
	entry $t.es -bd 2 -relief sunken -width 40
    	menubutton $t.mbHist -bd 2 -relief raised \
		-bitmap @$tkdesk(library)/cb_tools/bitmaps/combo.xbm \
		-menu $t.mbHist.menu
    	menu $t.mbHist.menu \
		-postcommand "hsearch_history buildmenu $t.mbHist.menu"
	# add dummy entry to work around bug in pre Tk 4.0p2:
	$t.mbHist.menu add command -label "dummy"
	hsearch_history changed
	pack $t.es \
		-in $t.fsf -side left -fill x -expand yes \
		-ipady 2 -pady $tkdesk(pad)
	pack $t.mbHist \
		-in $t.fsf -side left \
		-padx $tkdesk(pad) -pady $tkdesk(pad) -ipadx 2 -ipady 2
	bind $t.es <Escape> "destroy $t"
	bind $t.es <Return> "
	    $this _do_hsearch
	    hsearch_history add \[list \[$t.es get\]\]
	"

	frame $t.fm -bd 1 -relief raised
	pack $t.fm -fill both -expand yes
	frame $t.fmf
	pack $t.fmf -in $t.fm -fill both -expand yes \
		-padx $tkdesk(pad) -pady $tkdesk(pad)
	label $t.lMatches -text "Matches:" -anchor w
	pack $t.lMatches -in $t.fmf -fill x
	cb_listbox $t.flb -vscroll 1 -hscroll 1 -lborder 0 -uborder 1 \
		-width 10 -height 4 \
		-font [cb_font $tkdesk(editor,font)] -setgrid 1 \
		-selectmode single
	# $t.flb config -bd 1 -relief raised
	pack $t.flb -in $t.fmf -fill both -expand yes
	bind $t.flb.lbox <1> "
	    %W selection clear 0 end
	    set tmplbi \[%W  nearest %y\]
	    %W selection set \$tmplbi
	    $this _hsearch_callback \$tmplbi
	    unset tmplbi
	"

	frame $t.fb -bd 1 -relief raised
	pack $t.fb -fill x
	cb_button $t.bSearch -text " Search " \
		-command "$this _do_hsearch ; \
		          hsearch_history add \[list \[$t.es get\]\]" \
		-default 1
	cb_button $t.bClose -text "  Close  " -command "destroy $t"
	cb_button $t.bRemove -text " Remove Entry " \
		-command "hsearch_history remove \[$t.es get\]"
	pack $t.bSearch $t.bClose \
		-in $t.fb -side left \
		-padx $tkdesk(pad) -pady $tkdesk(pad)
	pack $t.bRemove \
		-in $t.fb -side right \
		-padx $tkdesk(pad) -pady $tkdesk(pad)

	bind $t <Any-Enter> "if \$tkdesk(focus_follows_mouse) \{focus $t.es\}"
	
	wm title $t "HyperSearch"
	wm minsize $t 6 2
	wm geometry $t 20x6
	wm group $t $this
	cb_deiconify $t
    }

    method _hsearch_callback {line_nr} {
	$this.ft.text yview [expr [lindex $hsearch_lnr $line_nr] - 1]
	$this.ft.text mark set insert $line_nr.0
    }

    method _do_hsearch {} {
	global [set this]

	set exp [$this-hsearch.es get]
	if {$exp == ""} return

	set t "$this-hsearch"
	set lb "$t.flb.lbox"
	$lb delete 0 end

	dsk_busy
	if ![set [set this](case)] {
	    set err [catch {set grep_output \
		    [exec egrep -ni -e $exp << [$this.ft.text get 1.0 end]]}]
	} else {
	    set err [catch {set grep_output \
		    [exec egrep -n -e $exp << [$this.ft.text get 1.0 end]]}]
	}
	if $err {
	    dsk_lazy
	    dsk_bell
	    return
	}
	if [set [set this](sort)] {
	    set grep_output [exec echo $grep_output | sort -t : +1]
	}
	set grep_output [split $grep_output \n]

	set hsearch_lnr ""
	foreach match $grep_output {
	    set lnr [string range $match 0 [expr [string first : $match] - 1]]
	    lappend hsearch_lnr $lnr
	    $lb insert end [string range $match \
		    [expr [string first : $match] + 1] end]
	}
	dsk_lazy
    }

    
    method findsel {} {
	global [set this] cb_Text
	
	set tw $this.ft.text
	set selr [$tw tag ranges sel]
	catch "unset cb_Text(selstart)"
	if {$selr != ""} {
	    set exp [$tw get [lindex $selr 0] [lindex $selr 1]]
	    dsk_busy
	    if ![set [set this](case)] {
		set success [regexp -nocase -indices -- \
			$exp [$tw get insert end] mrange]
	    } else {
		set success [regexp -indices -- \
			$exp [$tw get insert end] mrange]
	    }
	    dsk_lazy
	    if $success {
		selection clear $tw
		set mstart [lindex $mrange 0]
		set mend [expr [lindex $mrange 1] + 1]
		$tw tag add sel "insert + $mstart chars" "insert + $mend chars"
		$tw yview -pickplace "insert + $mstart chars"
		$tw mark set insert "insert + $mend chars"
	    } else {
		dsk_bell
	    }
	} else {
	    dsk_bell
	}
    }

    method setfont {{what ""}} {
	global tkdesk
	
	if {$what == "default"} {
	    $this.ft.text config -font [cb_font $tkdesk(editor,font)]
	} else {
	    set font [cb_fontSel]
	    if {$font != ""} {
		if [winfo exists $this.ft.text] {
		    $this.ft.text config -font [cb_font $font]
		}
	    }
	}
    }

    method set_auto_indent {} {
	global [set this]

	set m $this.fMenu.mbOptions.menu
	set me [$m index " Indent after*"]
	if [set [set this](auto_indent)] {
	    catch {$m entryconfigure $me -state normal}
	    bind $this.ft.text <Return> {
		cb_Text_change_callback %W insert <return>
		set tmpline [%W get "insert linestart" "insert"]
		regexp {^[	 ]*} $tmpline tmpmatch
		set tmpchar [%W get "insert - 1 chars"]
		%W insert insert "\n$tmpmatch"
		%W yview -pickplace insert
		if [set [winfo toplevel %W](brace_indent)] {
		    if {$tmpchar == "\{"} {
			[winfo toplevel %W] _tabstr
		    }
		}
		unset tmpline tmpmatch
		break
	    }
	} else {
	    catch {$m entryconfigure $me -state disabled}
	    bind $this.ft.text <Return> {
		cb_Text_change_callback %W insert <return>
		%W insert insert \n
		%W yview -pickplace insert
		break
	    }
	}
    }

    method set_quick_load {} {
	global tkdesk [set this]

	if [set [set this](quick_load)] {
	    catch {::set tkdesk(quick_load_editor) $this}
	} else {
	    catch {::unset tkdesk(quick_load_editor)}
	}
    }

    method set_line_wrap {} {
	global [set this] tkdesk

	$this.ft.text config -wrap [set [set this](wrap)]
	set tkdesk(editor,wrap) [set [set this](wrap)]
    }

    method set_tab_string {{ask 1}} {
	global [set this] tkdesk

	if [set [set this](realtabs)] {
	    bind $this.ft.text <Tab> {
		cb_Text_change_callback %W insert <tab>
		%W insert insert \t
		%W yview -pickplace insert
		break
	    }
	} else {
	    if $ask {
		set val [cb_readString "Tab Width (Spaces):"]
		if {$val == ""} {
		    set tkdesk(editor,tab_width) 8
		} else {
		    set tkdesk(editor,tab_width) $val
		}
	    }
	    bind $this.ft.text <Tab> "$this _tabstr; break"
	}
    }

    method _tabstr {} {
	global [set this] tkdesk

	set w $this.ft.text
	#cb_Text_change_callback $w insert
	if [set [set this](realtabs)] {
	    set tmpstr "\t"
	} else {
	    set tmpci [lindex [split [$w index insert] .] 1]
	    set tmpval [expr $tkdesk(editor,tab_width) - \
		    $tmpci % $tkdesk(editor,tab_width)]
	    if !$tmpval {set tmpval $tkdesk(editor,tab_width)}
	    set tmpstr ""
	    for {set i 0} {$i < $tmpval} {incr i} {append tmpstr " "}
	}
	cb_Text_change_callback $w insert $tmpstr
	$w insert insert $tmpstr
	$w yview -pickplace insert
    }

    method _dd_drophandler {} {
	global DragDrop tkdesk

	catch "wm withdraw $tkdesk(dd_token_window)"
	update
	
	foreach file $DragDrop(file) {
	    $this buffer create $file
	}
    }

    method set_qmark {nr} {
	set qmark($nr) "$currentid [$this.ft.text index insert]"
    }
	
    method goto_qmark {nr} {
	if {$qmark($nr) == ""} {
	    dsk_bell
	    return
	} else {
	    set id [lindex $qmark($nr) 0]
	    set idx [lindex $qmark($nr) 1]
	    set qmark(0) "$currentid [$this.ft.text index insert]"
	    $buffer($id,win) buffer display $id
	    $buffer($id,win).ft.text see $idx
	    $buffer($id,win).ft.text mark set insert $idx
	}
    }
	
    method popup {x y} {
	if [file exists $buffer($currentid,file)] {
	    dsk_popup "" [cb_tilde $buffer($currentid,file) expand] $x $y
	}
    }
    
    proc id {{cmd ""}} {
	if {$cmd == ""} {
	    set i $object_id
	    incr object_id
	    return $i
	} elseif {$cmd == "reset"} {
	    set object_id 0
	}
    }

    proc bufferMenu {menu {win ""}} {
	global tkdesk

	# sort the buffer names
	set l {}
	for {set id 1} {$id <= $bufcount} {incr id} {
	    if ![info exists buffer($id,file)] continue
	    set fname [file tail $buffer($id,file)]
	    lappend l [list $fname $id]
	}
	set l [lsort $l]
	
	catch "$menu delete 0 last"
	set ne 0
	foreach b $l {
	    set id [lindex $b 1]
	    if ![info exists buffer($id,file)] continue
	    if ![info exists changed($id)] continue
	    if {$win != ""} {
		set currentid [$win info protected currentid -value]
	    } else {
		set currentid -1
	    }
	    if [file exists $buffer($id,file)] {
		set fname "[lindex $b 0]  ([cb_tilde [file dirname $buffer($id,file)] collapse])"
	    } elseif [file exists [file dirname $buffer($id,file)]] {
		set fname "[lindex $b 0]  ([cb_tilde [file dirname $buffer($id,file)] collapse])"
	    } else {
		set fname $buffer($id,file)
	    }
	    if {$id == $currentid} {
		if $changed($id) {
		    set l "@$fname"
		} else {
		    set l ">$fname"
		}
	    } else {
		if $changed($id) {
		    set l "*$fname"
		} else {
		    set l " $fname"
		}
	    }
	    incr ne
	    if {$ne > $tkdesk(_max_menu_entries)} {
		$menu add cascade -label "More..." -menu [set menu $menu.c$ne]
		catch {destroy $menu}
		menu $menu
		set ne 0
	    }
	    $menu add command -label $l \
		    -font [cb_font $tkdesk(font,file_lbs)] \
		    -command "$buffer($id,win) buffer display $id"
	    
	}
    }

    proc save_all {} {
	for {set id 1} {$id <= $bufcount} {incr id} {
	    if ![info exists buffer($id,file)] continue

	    if $changed($id) {
		#$buffer($id,win) buffer display $id
		$buffer($id,win) save "" 0 $id
	    }
	}
    }

    proc load_or_display {w file} {

	# see if this file is already loaded
	for {set id 1} {$id <= $bufcount} {incr id} {
	    if ![info exists buffer($id,file)] continue
	    if {$buffer($id,file) == $file} {
		$buffer($id,win) buffer display $id
		return
	    }
	}
	
	if [winfo exists $w] {
	    $w buffer create $file 0 0
	}
    }

    #
    # ----- Variables ---------------------------------------------------------
    #

    public files "" {
	set dont_display 1
	set id -1
	foreach f $files {
	    dsk_status "Loading $f..."
	    if {$id == -1} {
		set id [$this buffer create $f]
	    } else {
		$this buffer create $f
	    }
	}
	set dont_display 0
	if {$id != -1} {
	    $this buffer display $id
	}
	dsk_status_ready
    }

    public name "" {
	
	set buffer($currentid,file) $name
	wm title $this [cb_tilde $name collapse]
	wm iconname $this "[file tail $name]"
    }

    protected currentid -1
    protected match_range ""
    protected search_regexp ""
    protected hsearch_lnr ""
    protected autosavecount 0
    protected autosaveperiod 500
    protected undo_size 500
    protected dont_display 0

    common buffer
    common bufcount 0
    common changed
    common object_id 0
    common cutbuffer ""
    common searchexp ""
    common qmark
    common undo_enabled
    common undo_list
    common undo_pointer
    for {set i 0} {$i < 10} {incr i} {
	set qmark($i) ""
    }
}

#
# -----------------------------------------------------------------------------
#
# Proc:		dsk_editor
# Args:		cmd	command to invoke
#		args	other arguments
# Returns: 	""
# Desc:		Meta function to access the built-in editor.
# Side-FX:	none
#

set dsk_editor(cnt) 0
proc dsk_editor {cmd args} {
    global dsk_editor tkdesk dsk_exec

    set w ""
    switch -- $cmd {
	new {
    	    set w .de[dsk_Editor :: id]
	    dsk_Editor $w
	    $w buffer new {}
	}
	load {
	    set w .de[dsk_Editor :: id]
	    dsk_Editor $w
	    foreach file $args {
		$w buffer create $file
	    }
	}
	string {
	    set w .de[dsk_Editor :: id]
	    dsk_Editor $w
	    $w buffer new {}
	    eval $w.ft.text insert end $args
	    # $w _changing
	}	    
	delall {
	    foreach obj [itcl_info objects -class dsk_Editor] {
		catch {$obj close_win}
	    }
	}
	fileview {
	    set w [lindex $args 0]
	    set file [lindex $args 1]
	    if ![winfo exists $w] {
		set w .de[dsk_Editor :: id]
		dsk_Editor $w
		set dsk_editor($w,viewerid) ""
	    }
	    if {$dsk_editor($w,viewerid) != ""} {
		$w buffer delete $dsk_editor($w,viewerid) 1
	    }
	    set ret [$w buffer create $file 0 0]
	    set dsk_editor($w,viewerid) $ret
	}
	quickload {
	    set w [lindex $args 0]
	    if ![winfo exists $w] {
		catch {unset tkdesk(quick_load_editor)}
		return
	    }
	    set file [lindex $args 1]
	    dsk_Editor :: load_or_display $w $file
	}
	cmd {
	    set cnt [incr dsk_editor(cnt)]
	    set cmd $args
	    if [info exists dsk_exec(dir)] {
		if [file isdirectory $dsk_exec(dir)] {
		    cd $dsk_exec(dir)
		} else {
		    unset dsk_exec(dir)
		}
	    } else {
		cd [dsk_active dir]
	    }

	    # move this block here to handle immediate exit of blt_bgexec
	    dsk_status "Launched:  $cmd"
	    dsk_lazy
	    
	    if $tkdesk(exec_as_root) {
		set cmd [string_replace $tkdesk(cmd,su,view) %c $cmd]
		dsk_debug "SU-View: $cmd"
	    }

	    if {[string first " <" $cmd] < 0} {
		set devnull "</dev/null"
	    } else {
		set devnull ""
	    }
	    dsk_debug "cmd: $cmd"
	    dsk_debug "devnull: \"$devnull\""

	    if $dsk_exec(shell) {
		set dsk_exec(shell) 0
		eval blt_bgexec dsk_editor(stat$cnt) \
			-output dsk_editor(result$cnt) \
			-error dsk_editor(error$cnt) \
			sh -c [list "exec $cmd"] $devnull &
		tkwait variable dsk_editor(stat$cnt)
	    } else {
		eval blt_bgexec dsk_editor(stat$cnt) \
			-output dsk_editor(result$cnt) \
			-error dsk_editor(error$cnt) \
			$cmd $devnull &
		tkwait variable dsk_editor(stat$cnt)
	    }
	    
	    dsk_status "Exit:  $cmd"
	    cd ~
	    if $tkdesk(exec_as_root) return

	    set w .de[dsk_Editor :: id]
	    dsk_Editor $w
	    $w buffer new {}
	    if {$dsk_editor(result$cnt) != ""} {
		$w.ft.text insert end "$dsk_editor(result$cnt)\n"
	    }
	    if {$dsk_editor(error$cnt) != ""} {
		$w.ft.text insert end "$dsk_editor(error$cnt)\n"
	    }
	    $w.ft.text mark set insert 1.0
	    $w config -name "$cmd (Output)"
	    if [info exists dsk_exec(dir)] {
		dsk_refresh $dsk_exec(dir)
		unset dsk_exec(dir)
	    }
	}
    }

    return $w
}

proc dsk_editor_hsearch_cb {t exp} {
    $t.es delete 0 end
    set re [string trimright [string trimleft $exp \{] \}]
    regsub \\\\{ $re \{ re ;# yes, FOUR slashes in the first arg! 
    regsub \\\\} $re \} re
    $t.es insert end $re
}
