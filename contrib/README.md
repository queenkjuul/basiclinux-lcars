# `contrib`

This directory contains "contrib" files. This includes entire mirrors of the sites linked from the main BasicLinux docs which contain add-ons, modules, packages, and more documentation. Some sites have been lost to time, but as many as I could find are here.

In the `ftp.dnslb.sjtu.edu.cn` folder (shortcut [opera/](./opera)) there is a stash of the last remaining copies of Opera 7-9 I could find online. Untested, not guaranteed to be safe! Use at your own risk! I will update with news if anything bad happens...

## Extra files

opera-7.11....tar.gz: unsupported, old version of Opera 7 I found online before I found the above-linked mirror

root_fs_i386.ext.bz2: uclibc toolchain image. No longer hosted, but available on archive.org, so linked here. Generally doesn't actually work inside BL3, hence its exclusion from the CD. Use on a modern machine to build BusyBox binaries which work on BL3.

vitetris-0.59.1.tar.gz: the upstream vitetris source archives don't open on BL3, so this is a repack. Must configure with `./configure --without-netplay --without-menu --without-joystick` to build it, but it will build (binary packages already installed and provided in `LiveCD/packages/contrib`)

pacman_10.orig.tar.gz: upstream pacman sources from Debian, does not build as-is
pacman_10.diff.tar.gz: upstream diff from Debian, used for inspiration
pacman_10-bl3.tar.gz: modified pacman sources, updated to build on BasicLinux. Binaries already installed and in `LiveCD/packages/contrib`

tclapps-master.zip: source for the included Tk apps (asteroids, breakout, frogger, TkVNC)

dillo-0.8.6-glibc225.gz: gzip'd binary build of dillo-0.8.6, as yet untested, but should work with Slack9 glibc-2.3.1. If it does, it will be moved to the main package repo.

## OG BasicLinux Docs

in the [`distro.ibiblio.org`](./distro.ibiblio.org/baslinux/) directory, there is the original BasicLinux documentation as well as all of the original BasicLinux 3 downloads, mirrored direct from the main site. The package and module files have been redistributed around the LiveCD image for ease of use, but the site is available in its original layout here.

## HELP: WANTED!

I have attempted to archive each of the links from the [Official BasicLinux Contrib page](https://distro.ibiblio.org/baslinux/contrib.html) into this directory. All but `http://www.johnbeck.org/bl3` were either still alive or mirrored on `archive.org`.

If you have the files/documentation from that old `johnbeck.org` link, please open an issue and let me know!
