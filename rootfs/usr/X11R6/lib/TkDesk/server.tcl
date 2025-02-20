# =============================================================================
#
# File:		server.tcl
# Project:	TkDesk
#
# Started:	02.05.97
# Changed:	02.05.97
# Author:	cb
#
# Description:	Implements the server stuff.
#
# Copyright (C) 1996, 1997  Christian Bolik
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
#
# =============================================================================

# -----------------------------------------------------------------------------
# dsk_setup_server:
# Sets up the server socket.
#
proc dsk_setup_server {} {
    global tkdesk dsk_server

    #puts "in: $tkdesk(tkdesk_server)"
    if [file readable /tmp/tkdesks[pid]] {
	# server already running -> shut it down
	dsk_shutdown_server
	set tkdesk(tkdesk_server) 0
	return
    }

    set s 29
    catch {set s [string trimleft [exec date +%S] 0]}
    if {$s == ""} {set s 29}
    set port [expr [file atime \
	    [file dirname $tkdesk(library)]] % (553 * $s) - $s + [pid]] 
    while {$port < 1025} {incr port [pid]}
    while {$port > 32767} {incr port -[pid]}

    # open socket:
    set cnt 1
    while {$cnt} {
	set cnt [catch {set dsk_server(s_channel) \
		[socket -server "_dsk_server_connect" $port]}]
	incr port
    }
    set fd [open /tmp/tkdesks[pid] w 0600]
    puts $fd [expr $port -1]
    close $fd
    
    set tkdesk(tkdesk_server) 1
    #puts "out: $tkdesk(tkdesk_server)"
}

# -----------------------------------------------------------------------------
# dsk_shutdown_server:
# Removes the socket file from /tmp.
#
proc dsk_shutdown_server {} {
    global dsk_server

    catch {close $dsk_server(s_channel)}
    catch {exec rm -f /tmp/tkdesks[pid]}
}

# -----------------------------------------------------------------------------
# _dsk_server_connect:
# Gets invoked when a client connects to our socket.
#
proc _dsk_server_connect {ch clAddr clPort} {
    global tkdesk dsk_server
    
    if {$clAddr != "127.0.0.1"} {
	catch {puts stderr "TkDesk: rejected connection from $clAddr"}
	close $ch
	return
    }

    fileevent $ch readable "_dsk_server_read $ch"
}

# -----------------------------------------------------------------------------
# _dsk_server_read:
# Reads remaining bytes from the socket channel.
#
proc _dsk_server_read {ch} {
    global tkdesk
    
    fileevent $ch readable {}
    set cmd [read $ch]
    #puts $cmd

    set res ""
    set err [catch {set res [eval $cmd]} errmsg]
    #puts $ch $res
    #flush $ch
    #close $ch
    
    if $err {
	cb_error $errmsg
    }
}

