# BasicLinux LiveCD Extras

The Extras folder contains some browsers, useful source code, and various things that didn't fit on the CD.

**The following is not necessarily an up-to-date list, but it is a guide to locating the truncated filenames on the LiveCD**

slackwar:      slackware-9.0/ - contains glibc2 from slackware-9, see BasicLinux "library upgrade" docs

bbox-101.bz2:   busybox-1.01.tar.bz2 - sources for version of busybox used in initrd

krnlsrc.bz2:   linux-2.2.26.tar.bz2 - sources for kernel version used in BasicLinux
krnlcfg.txt:    linux-2.2.26.config  - kernel config for BasicLinux 3.5 (use to build your own kernel)

opera-85.bz2:   opera-8.54-20060330.1-static-qt.i386-en.tar.bz2 - statically linked Opera 8.54 browser for Linux; supported but untested

opera-75.gz:   opera-7.54-static-qt-i386.tar.gz - statically linked Opera 7 browser for Linux; see BasicLinux docs (unsupported, untested)

opera-96.bz2    opera-9.64.gcc295-static-qt3.i386-nolocale.tar.bz2 - statically linked Opera 9.64 browser for Linux;
                modified by keesan.freeshell.org.
                requires operalibs.tgz from the GitHub repo (on paper) but may work with slackware-9.0 misc-libs.tgz;
                see docs in /contrib/keesan.freeshell.org.

No longer on the CD:

opera-71.bz2:   opera-7.11-20030515.1-static-qt.i386.tar.bz2 - statically linked Opera 7.11 browser for Linux; see BasicLinux docs (unsupported, untested)
uclibcrt.bz2:   root_fs_i386.ext2.bz2 - raw disk image, bzip2'd, containing the uclibc toolchain used to build initrd busybox

*** ONLY THE CONTENTS OF slackwar ARE INSTALLABLE SLACKWARE .TGZ PACKAGES ***
*** THE REST ARE ONLY USING THE .TGZ EXTENSION AS ISO9660 DOES NOT ALLOW .TAR.GZ / .TAR.BZ2 EXTENSIONS ***

## Customization

### Theory of Operation

The basic boot process goes like this:

1. MS-DOS boots from CD-ROM
2. MS-DOS loads CD-ROM drivers
3. MS-DOS calls `LOADLIN.EXE` from the CD
4. `LOADLIN` boots the Linux kernel
5. `initfs.gz/linuxrc` loads CD-ROM drivers
   1. Alternatively, `initfs.gz/linuxrc` calls `/floppy/drivers.sh` to load SCSI drivers
6. `initfs.gz/linuxrc` looks for `/baslin/FS.IMG` on each IDE block device
7. `initfs.gz/linuxrc` uses `losetup` to set up `FS.IMG` as `/dev/loop0`
8. Linux kernel continues boot using `/dev/loop0` as root

### Repo Explanation

#### `/cdboot`

Contents of the disk image `cdboot.ima`

Should be built into a `cdboot.ima` file that eventually becomes the "boot image" for ImgBurn. 

THIS IMAGE MUST BE MS-DOS BOOTABLE

The distributed `cdboot.ima` contains MS-DOS and BasicLinux-LCARS boot code. Replacing the disk image without preserving the boot code will not work. Preserve the boot code, or simple modify the provided images before building your ISO.

#### `/driverdisk`

Contents of the demonstration "Adaptec AHA-1542CP SCSI Driver Disk"

`driverdisk.ima` and the `/driverdisk` directory show how to load additional drivers in "SCSI" boot mode. You can run any arbitrary script, but the boot-init shell only has a handful of commands available (see the demonstration `/driverdisk/drivers.sh` for examples).

#### `/livecd`

Files which belong on the LiveCD root partition (separate from the `cdboot.ima` "emulated" CD boot disk image)

#### `/rootfs`

Files which belong in the `FS.IMG` root Linux system image.

**WARNING**: One does not simply `mke2fs -d /rootfs`' into a new ext2 image. The 2.2.x kernel does not support `devfs`, so any dev nodes must be present in the *read-only* `FS.IMG` prior to boot. It's best to copy the existing `FS.IMG`, and modify it, unless you really know what you're doing. The `/rootfs` directory is only for reference, not for immediate reuse.

Note that you'll need to add any new dev nodes to `/etc/ttyS0.img`, `/etc/ttyS1.img`, `/etc/psaux.img` as well if you want those devices to be accessible from Xvesa sessions.

The final `FS.IMG` image size of ~256MB is not totally arbitrary; this is approximately the maximum size while keeping all official add-ons installed and the full Slackware-4.0 package repo on-disc.

##### `/rootfs/etc/ttyS*.img, /rootfs/etc/psaux.img`

X is tricky to get running on a fully read-only filesystem (and in fact, it is not truly possible to do so entirely, the lock files in `/tmp` and `Xauthority` *must* be writable). Traditionally, to choose a mouse device with X, one simply symlinks `/dev/mouse` to the desired device - for example, `/dev/mouse -> /dev/ttyS0` for a serial mouse, or `/dev/mouse -> /dev/psaux` for a PS/2 mouse. On the LiveCD, `/dev` is read-only, so we cannot create the symlink. Initializing `/dev` as a RAMDISK at boot time would cost at least 160K of RAM, which is undesirable.

So instead, there are 3 separate `/dev` images, each with a different `/dev/mouse` symlink. `startx` will mount the appropriate one depending on which mouse the user indicates they want to use.

#### `/slackware`

Complete mirrors of the full Slackware 4.0 and 9.0 repositories, for posterity. Slackware 4 packages which run on BasicLinux are in the `/packages` directory already. Slackware 9 glibc2 libraries are included in `/extras`. The rest is merely for historical preservation.

#### `/contrib`

Mirrors of the add-on sites that still exist (some packages sadly lost to time)