This is a simple notepad editor writen in TCL/Tk.

ABOUT:   

Tk NotePad is designed to be a single Tcl/Tk script, that is functional cross 
platform, but is intended mainly for Linux.

This script is freeware, however there is some 'borrowed code' now contained in 
this script. See the file license.txt to see what that means. Basically I 
modified there code and am now redistributing it, and giving them proper credit.
As I understand it that is they way it works. This script itself then becomes 
yours to modify, crop, cut, paste, or whatever. It is distributed under the 
Tcl/Tk liscense, the licesnse.txt file, and I guess that makes it LGPL? I'm not
a lawyer, so don't ask me!

Once this script ends up on your machine I make no guarantees of any of its 
functionality. Currently all shown menus are functioning! It works on my 
machine and many others have reported much success and enjoyment :-). I have 
a DUAL P-233Mhz MMX, with 128Meg RAM running glibc2.1 Linux with Tcl/Tk8.0p2.
(RedHat6.0).

Originally Tcl version 7.6 was used in conjunction with Tk 4.2 then I upgraded 
to Tcl/TK 8.0 and I have tested it under Tcl/Tk 8.1.1 under Windows 95. Lately
I have added features which may not be available in versions earlier than 
Tcl/Tk8.0. So if you have problems and are not using 8.0 or later I can only 
suggest upgrading, sorry :-(. Tcl/Tk is free to use so why not get it from 
http://www.scriptics.com.

INSTALL

	see the file INSTALL to install this program

KNOWN BUGS:

	NONE! This is bug free software :-) AFAIK they have all been fixed. 
	If you find one please report it.

It should work on any platform that has the Tcl/Tk libs, but was designed for 
Linux.

KNOWN ISSUES:

	See the known issues file. These are 'bugs' that are known, but bugs in 
	the OS or implementation of Tcl/Tk.

TODO:
	Print Setup may be inhanced to let a user decide which output file to 
	temporarily write to? Currently it is /tmp/tkpadtmpfile. 
 	Maybe add print to Windows. 

NOTES on COMPLETION:

	As of the release of version 0.4.9 Tk NotePad was considered to be done.
	Work will be done on improving the program, by cleaning up the code. 
	So don't expect any new features except maybe the addition of a menu when 
	a user right clicks the mouse button in the text area (almost done). 
	Version 0.5.0 was released adding white to the text widget as the default 
	color as this was recommended by Linux Journal March 1999, Issue #59. I have 
	added in -fg color -bg color as well. There have been mainly only code 
	clean ups since 0.5.0 and some more 'configurability.' I have added 2 more 
	options in 0.6.5 -p and -f. The -p option allows one to pipe info into 
	tknotepad at the command line, e.g. ps -aux|tknotepad, will open tknotepad 
	with the output of ps -aux. That functionality is thanks to Jorn Poulson. 
	The args handling has been rewritten for the -f option which 'forks' a new 
	Tk NotePad, so a command like tknotepad file1.txt -f file2.txt -f file3.txt 
	would open 3 instances of Tk NotePad each with a seperate file.
	In version 0.6.9 I introduce 'feature' patches. These are file that can be
	added to the end of the tknotepad script itself to add special requested 
	features. See the INSTALL file for more info on those. Thanks to Scott Laufer for
     	the new window patch.

CHANGING SOME DEFAULTS

	1) To change the default Print Command look for the line
		set printCommand lpr
	and change to whatever you need or want.
	
	2) To change the font for the text are change the "textFont" variable at
	the top of the script. 

	3) To change the font for the menu are change the "menuFont" variable at
	the top of the script. 

	4) To change the default geometry change the line 
		wm geometry . 80x25
	and change the 80x25 to whatever size you like

WindowMaker NOTE:
	In windowmaker the window bindings may interfear with application binding, so this is 
	just an FYI. In my case the Atl-H of window maker is bound to the hide functionality.

NOTE:
	It works on Windows, but BETTER on Linux!

Questions / Comments

	email me: joseph-ja at earthlink.net

	Joseph Acosta
