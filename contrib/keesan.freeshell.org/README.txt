**********************************************************************
*** MOST OF THIS SOFTWARE IS NOT DESIGNED FOR BASICLINUX 3.5 (BL3) ***
*** AND AS SUCH WILL NOT WORK WITH THE BASICLINUX-LCARS LIVECD     ***
*** READ THE ACCOMPANYING DOCUMENTATION. MOST COMPATIBLE PACKAGES  ***
*** WILL ALREADY HAVE BEEN COPIED TO THE /PACKAGES DIRECTORY OF    ***
*** THE LIVECD IMAGE AND THE GITHUB REPO (/LIVECD/PACKAGES/CONTRIB)***
**********************************************************************
*** THE REST OF THIS SOFTWARE HAS BEEN MIRRORED HERE ONLY FOR THE  ***
*** SAKE OF PRESERVING BASICLINUX RESOURCES INTO THE FUTURE.       ***
**********************************************************************

The vast majority of these packages will require the glibc2 upgrade,
see the BasicLinux documentation on "Upgrading the Library" or 
"Installing Opera" for more details.

"contrib" packages (located in /livecd/packages/contrib unless noted):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ROSEGARDEN should be compatible but is not installed by default, 
	may require timidity (both in contrib). 
	Does require x-libs.tgz (installed in BL3-LCARS)

MPLAYER4 is already installed, the version provided in /livecd/packages/contrib
	works with BL3-LCARS and BL3.5

DROPBEAR-0.49-UCLIBC is already installed, but mostly untested

Modules in 2.2.26 subdirectory should work in theory but have not been tested,
so they are currently not included in the main LiveCD release (as of b1r4)