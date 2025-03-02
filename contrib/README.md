# `contrib`

This directory contains "contrib" files. This includes entire mirrors of the sites linked from the main BasicLinux docs which contain add-ons, modules, packages, and more documentation. Some sites have been lost to time, but as many as I could find are here.

In the `ftp.dnslb.sjtu.edu.cn` folder (shortcut [opera/](./opera)) there is a stash of the last remaining copies of Opera 7-9 I could find online. Untested, not guaranteed to be safe! Use at your own risk! I will update with news if anything bad happens...

## Extra files

opera-7.11....tar.gz: unsupported, old version of Opera 7 I found online before I found the above-linked mirror

root_fs_i386.ext.bz2: uclibc toolchain image. No longer hosted, but available on archive.org, so linked here. Generally doesn't actually work inside BL3, hence its exclusion from the CD.

vitetris-0.59.1.tar.gz: the upstream vitetris source archives don't open on BL3, so this is a repack. Must configure with `./configure --without-netplay --without-menu --without-joystick` to build it, but it will build (binary packages already installed and provided in `LiveCD/packages/contrib`)

pacman_10.orig.tar.gz: upstream pacman sources from Debian, does not build as-is
pacman_10.diff.tar.gz: upstream diff from Debian, used for inspiration
pacman_10-bl3.tar.gz: modified pacman sources, updated to build on BasicLinux. Binaries already installed and in `LiveCD/packages/contrib`

tclapps-master.zip: source for the included Tk apps (asteroids, breakout, frogger, TkVNC)

## OG BasicLinux Docs

in the [`distro.ibiblio.org`](./distro.ibiblio.org/baslinux/) directory, there is the original BasicLinux documentation as well as all of the original BasicLinux 3 downloads, mirrored direct from the main site. The package and module files have been redistributed around the LiveCD image for ease of use, but the site is available in its original layout here.
