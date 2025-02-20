# BasicLinux 3.5 LCARS

**L**ive **C**D **A**nd **R**escue **S**ystem

*Sister project to [LCARS-DOS](https://github.com/queenkjuul/LCARS)*

Perhaps the only bootable Linux LiveCD that can run on a 386 with 4MB of RAM. Works whether your machine can CD-boot or not.

![BasicLinux 3.5 LCARS running in PCem *booted from CD* on a 386DX33 with *3MB RAM*](./pcemfetch.png)

This LCARS distribution of BasicLinux 3.5 aims to provide:

- A complete LiveCD desktop environment
- A complete installable desktop environment
- A complete low-memory shell environment (386 + 4MB)
- An expansive on-disc package repository for post-install customization

The system boots via MS-DOS, so it can be started from the CD itself on native CD-booting BIOSes (including some SCSI BIOS), from an MS-DOS boot floppy (image included), or from an MS-DOS installation already present on a hard drive. Even Windows 9x (when booted into DOS mode) can boot the LiveCD.

Tested on a real-life 386DX-40 with 8MB of RAM, and an emulated "MR 386DX Clone" with 4MB of RAM, as well as various more "modern" real-metal x86 systems. Compatibility seems good in general, but if PCem is accurate, some particularly old 386 BIOSes may not be compatible, and the [optional] MS-DOS USB drivers may interfere with kernel init on certain systems.

- [BasicLinux 3.5 LCARS](#basiclinux-35-lcars)
  - [System Requirements](#system-requirements)
    - [Minimum](#minimum)
    - [Optional](#optional)
  - [Features](#features)
    - [BasicLinux native features](#basiclinux-native-features)
    - [LiveCD Features](#livecd-features)
      - [BasicLinux `fetch`](#basiclinux-fetch)
  - [Booting](#booting)
    - [Boot Parameters](#boot-parameters)
    - [IDE/ATAPI CD-ROM](#ideatapi-cd-rom)
    - [BasicLinux-supported SCSI CD-ROM](#basiclinux-supported-scsi-cd-rom)
    - [Non-CD-bootable BIOS (Floppy Boot)](#non-cd-bootable-bios-floppy-boot)
    - [USB Boot (untested)](#usb-boot-untested)
    - [USB HID (keyboard + mouse)](#usb-hid-keyboard--mouse)
    - [Swap](#swap)
  - [Usage](#usage)
    - [Additional Hardware](#additional-hardware)
    - [Network](#network)
    - [Xvesa](#xvesa)
    - [Gimp](#gimp)
    - [glibc2 and Opera](#glibc2-and-opera)
    - [Java](#java)
    - [Installation](#installation)
      - [Transfer LiveCD System to MS-DOS installation](#transfer-livecd-system-to-ms-dos-installation)
      - [Install alongside MS-DOS to an ext2 partition](#install-alongside-ms-dos-to-an-ext2-partition)
    - [Swap](#swap-1)
  - [Customizing](#customizing)
    - [Theory of Operation](#theory-of-operation)
    - [Building the ISO](#building-the-iso)
      - [ImgBurn](#imgburn)
      - [WinImage](#winimage)
      - [Building BusyBox](#building-busybox)
      - [`initfs.gz`](#initfsgz)
      - [`FS.IMG`](#fsimg)
    - [Repo Explanation](#repo-explanation)
      - [`/cdboot`](#cdboot)
      - [`/driverdisk`](#driverdisk)
      - [`/livecd`](#livecd)
      - [`/rootfs`](#rootfs)
        - [`/rootfs/etc/ttyS*.img, /rootfs/etc/psaux.img`](#rootfsetcttysimg-rootfsetcpsauximg)
      - [`/slackware`](#slackware)

## System Requirements

### Minimum

- Intel 386
- 4MB RAM
- CD-ROM drive

### Optional

- 8MB RAM (to run Xvesa)
- Floppy drive (for non-CD-bootable BIOS, or to load SCSI/USB CD-ROM drivers)
- Mouse (for Xvesa) (PS/2 or Serial; USB drivers can be manually installed from `/modules`)
- 320MB free HDD space (for permanent installation)

## Features

### BasicLinux native features

The upstream BasicLinux project ships with:

- Linux kernel 2.2.26
- Busybox 1.01
- Xvesa
- JWM
- e3 editor (emulates vi/pico/wordstar)
- Slackware 4.0 package compatibility
- Installable to HDD (dual boot with MS-DOS, with or without a separate partition)

### LiveCD Features

- All BasicLinux official add-on packages
  - Includes large suite of installed software, including:
    - Network software (dropbear, httpd, smbclient, samba, netatalk, rsync)
    - Utilities (cdutils, ImageMagick, hfsutils, mpg123, mplayer, mc)
    - Development tools (gcc, automake, yabasic, perl, python 1.5, JDK 1.1.7/Java 7)
    - Desktop applications (AbiWord, Gimp, Xpaint, TkDesk, MagicPoint)
    - Games (Xfreecel, LinCity, Koules, matanza)
    - And many more!
- All BasicLinux official add-on kernel modules
- Full Slackware 4.0 binary package repository
  - `xemacs` is only package cut from CD to save space (60MB)
- Boots from SCSI and USB CD drives using a boot floppy
- Bootable MS-DOS rescue environment
  - Based on Windows 98 Setup Boot Disk
  - Includes CD-ROM drivers
  - Includes:
    - EDIT.COM
    - FDISK
    - FORMAT (Win98)
    - PKZIP/PKUNZIP
    - SCANDISK (Win98)
    - XCOPY
    - Some "UNIX"-iness: GREP, LS, RM, TREE
  
#### BasicLinux `fetch`

for your /r/vintagecomputing screenshots, you can run `fetch` on the LiveCD. (also, I'd love to see them - open an Issue, I guess?)

```
        #####         qkj@MainBridge
       #######        --------------------------------
       ##O#O##        OS:         Linux
       #VVVVV#        Kernel:     5.15.167.4-microsoft-standard-WSL2
     ##  VVV  ##      Arch:       x86_64
    #          ##     Uptime:     up 17:37
   #            ##    CPU Vendor: AuthenticAMD
   #            ###   CPU Model:  AMD Ryzen 7 5800X 8-Core Processor
  QQ#           ##Q   CPU Freq.:  3792.876 MHz
QQQQQQ#       #QQQQQQ Memory:     788892K (7294836K used)
QQQQQQQ#     #QQQQQQQ Swap:       0K (2097152K used)
  QQQQQ#######QQQQQ

          -= fetch for BasicLinux 3.5 LCARS LiveCD =-
                     Live Long and Prosper
```

## Booting

### Boot Parameters

The various boot scripts (`BOOT.BAT`, `SCSI.BAT`, `HDBOOT.BAT`) all accept arguments which are passed to the kernel command line.

The following parameters are available:

`usbhid` - install USB mouse+keyboard drivers at boot time

`usbstor` - install USB storage drivers at boot time

`ide-cd` - install IDE CD-ROM drivers at boot time (default in `BOOT.
BAT`/LiveCD)
`swapoff` - do not look for swap files on DOS partitions at boot

`norootverify` - skip root filesystem check at boot


### IDE/ATAPI CD-ROM

Systems with a native CD-bootable BIOS and an ATAPI/IDE/PATA CD-ROM drive should be able to boot automatically out-of-the-box, without any manual intervention.

Please note that BasicLinux will only automatically boot from the first detected CD-ROM drive. The only way to override this is to boot into the DOS prompt, unload `SHSUCDX`, and re-load it, assigning the appropriate drive letter to the appropriate unit. See the SHSUCDX documentation in `/docs` for details.

### BasicLinux-supported SCSI CD-ROM

If there is an official BasicLinux kernel module for your SCSI card (for example, the AHA-1542), then you can load it from a floppy disk at boot time. You will need to manually prepare a driver installer floppy, which contains the relevant kernel module files (e.g. `aha1542.o, sr_mod.o, scsi_mod.o`) and a script called `drivers.sh` which loads them in the correct order and mounts the CD-ROM to `/DOS`. See the `driverdisk` directory for an example. Remember to pass any relevant parameters on the `insmod` command line. The floppy should be DOS formatted (FAT16/FAT12). Available modules are in `LiveCD/modules`.

All SCSI devices require `scsi_mod.o` installed first. All SCSI CD-ROM devices require `sr_mod.o` installed. Additional SCSI device drivers are in `/modules/scsi` on the LiveCD.

At boot time, choose Option 2, "Boot BasicLinux and load additional drivers from floppy"

While not tested, USB drivers can be installed here as well. You may run into issues with the `/dev/` nodes for USB not being present. See [Customization](#customizing) or open a GitHub issue for help.

SCSI drivers will not automatically be installed after boot, you may need to reload them with `modprobe` (and add the commands to `/etc/rc` after installing to HDD)

### Non-CD-bootable BIOS (Floppy Boot)

If your system cannot natively boot from CD-ROM, Use the `cdboot.ima` file to create a bootable floppy disk (`dd` on Linux or `RAWRITE` on DOS, included in `/cdboot`). This provides an identical boot environment to the one provided on the LiveCD, including a fairly well stocked MS-DOS rescue environment.

If you cannot write the provided image to disk, you can boot from any MS-DOS disk with CD-ROM support (such as a Windows 9x installer boot floppy) and then navigating to the boot directory on your CD drive (probably `D:\BASLIN`) and then running `BOOT.BAT` or `SCSI.BAT`. Use `SCSI.BAT` only if you need to manually load CD-ROM drivers from floppy.

Any MS-DOS installation with CD-ROM drivers can boot the live CD, including one installed on a hard drive. Simply navigate to the `BASLIN` directory on the CD and run `BOOT.BAT` (or `SCSI.BAT`)

### USB Boot (untested)

BasicLinux shipped many USB driver modules. The MS-DOS portion of the boot stage will scan for USB CD-ROM devices (in "SCSI" mode). You can write `cdboot.ima` to a floppy, and if MS-DOS successfully detects your CD-ROM drive, then it should be possible for you to craft a driver install disk that can load the Linux USB CD-ROM drivers.

You must select Boot Option 2: "BasicLinux and load drivers from floppy" to trigger the USB device detection.

See the [SCSI documentation](#basiclinux-supported-scsi-cd-rom) and the `/driverdisk` directory for details on setting up a driver install floppy. You probably need `cdrom` (for all cdroms), `usbcore`, `usb-uhci` or `usb-ohci` or `uhci` (can just try them all), `usb-storage`, and `isofs` (if USB CD), in roughly that order.

### USB HID (keyboard + mouse)

Pass the string `usbhid` on the kernel command line.

From the LiveCD, choose "Option 3: Enter DOS Prompt" and from `Z:\BASLIN` run:

    boot usbhid

Or if you want to install additional drivers from floppy (such as SCSI or USB CD-ROM drivers):

    scsi usbhid

You can install USB HID drivers while in the LiveCD environment by calling `/usr/bin/usbhid`. You can edit `/etc/rc` to run this at boot, or you can permanently add `usbhid` to your `hdboot.bat`

### Swap

For severely RAM-restricted systems with an existing MS-DOS hard disk installation, you can place `SWAP.IMG` (unzip `SWAP.ZIP` on the LiveCD) as `C:\BASLIN\SWAP.IMG`, and as long as your MS-DOS partition is the first partition on the first disk, BasicLinux will find and utilize the swap file. This is not tested nor expected to work with SCSI drives, unless you  manually figure it out in your `drivers.sh` file.

## Usage

The boot CD has all official BasicLinux packages and modules already installed. Not all of them have X11 menu shortcuts, so check out the various `$PATH` directories to see what's available.

The system boots with a read-only root filesystem.

BasicLinux eschews the traditional multi-user UNIX paradigm in favor of just dumping you straight in a root shell with no password. It's basically Linux for DOS users, `/etc/rc` is functionally your `CONFIG.SYS`.

After installation to hard drive, you can install Slackware 4.0 packages (located on `LiveCD/packages/slackwar`) by running `pkg package.tgz`

### Additional Hardware

See `/etc/rc` for examples on how to load drivers for additional hardware. While you cannot modify the file in the read-only live environment, you can manually run the commands described in the file to load drivers for your hardware.

The original BasicLinux BusyBox build does not include `modprobe`. The LiveCD distribution, though, does provide `modprobe`. All BasicLinux documentation will say to use `insmod` to install drivers; however, with this distribution you can use `modprobe` instead. In general, `modprobe` will automatically install any dependencies your module has. `insmod` will not, which means you will need to manually install each module in the correct order. `modprobe` will generally save you headaches, but it is not available in the pre-init `initfs` environment (i.e., you must use `insmod` in your `drivers.sh` if you're using a floppy to load drivers).

### Network

See `/root/netsetup` for examples of how to set up a network card. If you install the system to HDD, you can modify `/etc/rc` to automatically initialize the network on boot.

As mentioned above, you can use `modprobe` instead of `insmod` from the LiveCD to automatically install module dependencies.

For example, while the BasicLinux docs specify:

    insmod 8390
    insmod ne io=0x300

With the LiveCD you can simply:

    modprobe ne io=0x300

### Xvesa

Running `startx` from the LiveCD will run a script asking for your X config parameters. `jwm` and `icewm` are installed by default. Only PS/2 and Serial (COM1/COM2) mice are supported by default.

After installing to the HDD, `startx` will automatically save your X configuration choices in `/etc/Xconfig`. If you need to adjust your configuration, edit that file; you can also delete the file entirely and re-run `startx` to generate a new config. Running `NOSAVEX=true startx` will run the script without saving your chosen config.

### Gimp

Gimp wants to load all of its Pattern files into RAM at startup. The version of Gimp shipped with BasicLinux includes 10MB of pattern files. Thus, no system with less than 12MB of RAM stands a chance of running Gimp out of the box.

To remove this requirement, all of the pattern files have been moved onto a disk image. By default, Gimp will see an empty `patterns/` directory, and load up in minimal-RAM environments (likely still about 12MB, mostly untested). If you have sufficient RAM and want to use patterns, you can run:

    mount -o loop /usr/share/gimp/patterns.img /usr/share/gimp/patterns

On a hard drive installation, you could then copy only the patterns you want to `~/.gimp/patterns` and unmount the disk image. This would conserve RAM while allowing you to still use the patterns feature.

### glibc2 and Opera

BasicLinux documentation indicates that Opera 8 will work with BasicLinux, if you first install the glibc2 packages from Slackware 9. The two library packages are in `LiveCD/extras/slackware-9.0`.

Unfortunately, I have been unable to locate a copy of Opera 8 for Linux. I have included Opera 7.54 instead. It is not yet tested.

If you find Opera 8 for Linux, statically linked for Qt (opera-8.xx-YYYYMMDD-static-qt-i386.tar.gz) please open an Issue and let me know.

See the BasicLinux documentation on-disc for more info.

### Java

JDK 1.1.7 is included in /usr/local/java and `java` binary is included in the PATH. This JDK distribution (originating from Slackware 4.0) includes custom wrapper scripts which are not compatible with 

### Installation

The system can be installed to a hard drive.

Installing to hard drive opens the opportunity to use alternative kernels or install additional Slackware 4.0 packages, which are located at `LivcCD/packages/slackwar` and installed by `pkg package.tgz`

There are two ways to do install to HD:

#### Transfer LiveCD System to MS-DOS installation

As the LiveCD itself boots via MS-DOS using `LOADLIN.EXE`, you can store the entire system on an MS-DOS partition and boot it from the DOS prompt as well.

The downside is that your root filesystem is limited to the 320MB LiveCD image file. Unfortunately BasicLinux 3.5 is so old as to predate `resize2fs`, so you're on your own as far as expanding the default root image. While the LiveCD image is ~300MB, only ~16MB of that is free space, so expect to store files on your MS-DOS partitions.

The easy way to do this from the LiveCD is as follows:

1. Boot the LiveCD and choose Option 3: Enter DOS Prompt
2. `mkdir C:\BASLIN`
3. `xcopy Z:\BASLIN C:\BASLIN` (press D when asked "file or directory")
4. (recommended, requires 16MB) copy `xcopy Z:\SWAP.ZIP C:\BASLIN\SWAP.ZIP;PKUNZIP C:\BASLIN\SWAP.ZIP`
5. (optional, requires 300MB) `xcopy Z:\PACKAGES C:\BASLIN\PACKAGES`
6. Reboot to MS-DOS from HDD
7. `cd C:\BASLIN;HDBOOT.BAT`

#### Install alongside MS-DOS to an ext2 partition

***CURRENTLY UNSUPPORTED, YOUR MILEAGE MAY VARY***

The install script works, but it does not create a boot floppy, fails to install a bootloader to the HDD, and misinforms the user as to how to boot the system. That said, it does successfully transfer the system to the ext2 partition, which can be booted manually with `LOADLIN`.

1. Create a new partition on your HDD using the LiveCD or MS-DOS `FDISK`
2. Format it as ext2 (`mke2fs /dev/hdxX`, probably `/dev/hda1` or `/dev/hda5`)
3. Mount it to `/hd` (`mount /dev/hdxX /hd`)
4. Run the install script: `install-to-hd`
5. Follow the prompts on screen

The installer will prompt you to create a boot floppy. This is recommended; alternatively, you can boot the HD installation from the LiveCD by choosing Option 3: "Enter DOS Prompt" and running:

    loadlin zimage root=/dev/hdxX rw

Where `hdxX` is where you installed BasicLinux, probably `hda2` or `hda5`

If you install to HDD using the first method (into an existing MS-DOS partition), and then afterwards install to an ext2 partition from there, you can skip the boot floppy and boot from MS-DOS by running the above command from `C:\BASLIN`. You can then delete `FS.IMG` (in fact, you can delete everything from `C:\BASLIN` except for `LOADIN.EXE`, `ZIMAGE`, and `SWAP.IMG`)

### Swap

Unzip `SWAP.ZIP` from the LiveCD to your `C:\BASLIN` directory (`xcopy Z:\SWAP.ZIP C:\BASLIN;pkunzip C:\BASLIN\SWAP.ZIP` from the LiveCD DOS prompt)

## Customizing

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

### Building the ISO

#### ImgBurn

Use ImgBurn to build the ISO. This probably works in Wine, but I have not tested this. When creating a Disc Image project in ImgBurn, you can specify a separate image file to use for 'boot device emulation'. We use `cdboot.ima` from this project to do that, which is a bootable Windows 98 (MS-DOS 7.1) boot image, modified to include a number of extra utilities. The Windows 98 image was chosen as it automatically loads a number of CD-ROM drivers. You can of course use any DOS image you like, as long as you can get it to read the rest of the CD. I have found that only the Floppy device emulation tends to work for booting old systems.

#### WinImage

I use WinImage to set up the DOS boot images from a modern Windows machine. You can, alternatively, just make a real life boot floppy in MS-DOS, and add the files you need to it, physically. From there you can image it back into ImgBurn. Also you could loop-mount the disk images with `-t msdos -o loop,rw` in Linux and modify them that way, then write them to disk.

#### Building BusyBox

Included in `/extras` of the repo and the LiveCD is the BusyBox-1.01 source code used to build the busybox binaries used in both the LiveCD and the `initfs.gz` init environment. The `initfs` version is built to be as small as possible, building to under 100K.

Building is done using the `uClib` build system. A copy of the system is included in `/extras` on the LiveCD. You can use it on a modern Linux system to build a compatible BusyBox binary.

1. Extract the root filesystem from the archive, mount it with something like `sudo mount -o loop,rw root_fs_i386.ext2 /path/to/mountpoint`.
2. You can then copy the BusyBox source into the root filesystem with something like `cp -r busybox-1.01 /path/to/mountpoint/busybox-1.01`.
3. chroot into the build directory `sudo chroot /path/to/mountpoint`
4. cd into the busybox directory `cd busybox-1.01`
5. Configure busybox:
   1. `make allnoconfig`
   2. `make config`
6. `make`
7. You may get errors at the end, but they're likely only for the docs step (not important)

#### `initfs.gz`

This is a `gzip`'d ext2 disk image. If you make a new image, you must use the `-r 0` argument with `mke2fs`. You want this to be as small as possible, as it loads into RAM entirely at boot. Any bigger than ~400K and you'll risk running out of RAM with 4MB.

You can place additional modules in `/lib/modules/2.2.26/misc` and load them via `linuxrc` using `insmod`.

#### `FS.IMG`

This is a raw ext2 filesystem image, again using `-r 0` with `mke2fs` for compatibility. 320MB is the largest image that will fit on a 650MB CDROM while still including the full set of documentation and packages.

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
