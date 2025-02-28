# BasicLinux 3.5 LCARS Boot Disk

This directory contains the files which constitute the BasicLinux 3.5 LCARS LiveCD boot system.

`CDBOOT.BIN` is the actual boot sector. If you only modify `CDBOOT.IMA` rather than replace it, you won't need the boot sector. Otherwise, be sure to use it.

## IDE/ATAPI CD-ROM

Systems with a native CD-bootable BIOS and an ATAPI/IDE/PATA CD-ROM drive should be able to boot automatically out-of-the-box, without any manual intervention.

Please note that BasicLinux will only automatically boot from the first detected CD-ROM drive. The only way to override this is to boot into the DOS prompt, unload `SHSUCDX`, and re-load it, assigning the appropriate drive letter to the appropriate unit. See the SHSUCDX documentation in `/docs` for details.

## BasicLinux-supported SCSI CD-ROM

If there is an official BasicLinux kernel module for your SCSI card (for example, the AHA-1542), then you can load it from a floppy disk at boot time. You will need to manually prepare a driver installer floppy, which contains the relevant kernel module files (e.g. `aha1542.o, sr_mod.o, scsi_mod.o`) and a script called `drivers.sh` which loads them in the correct order and mounts the CD-ROM to `/DOS`. See the `driverdisk` directory for an example. Remember to pass any relevant parameters on the `insmod` command line. The floppy should be DOS formatted (FAT16/FAT12). Available modules are in `LiveCD/modules`.

All SCSI devices require `scsi_mod.o` installed first. All SCSI CD-ROM devices require `sr_mod.o` installed. Additional SCSI device drivers are in `/modules/scsi` on the LiveCD.

At boot time, choose Option 2, "Boot BasicLinux and load additional drivers from floppy"

While not tested, USB drivers can be installed here as well. You may run into issues with the `/dev/` nodes for USB not being present. See [Customization](#customizing) or open a GitHub issue for help.

SCSI drivers will not automatically be installed after boot, you may need to reload them with `modprobe` (and add the commands to `/etc/rc` after installing to HDD)

## Non-CD-bootable BIOS (Floppy Boot)

If your system cannot natively boot from CD-ROM, Use the `cdboot.ima` file to create a bootable floppy disk (`dd` on Linux or `RAWRITE` on DOS, included in `/cdboot`). This provides an identical boot environment to the one provided on the LiveCD, including a fairly well stocked MS-DOS rescue environment.

If you cannot write the provided image to disk, you can boot from any MS-DOS disk with CD-ROM support (such as a Windows 9x installer boot floppy) and then navigating to the boot directory on your CD drive (probably `D:\BASLIN`) and then running `BOOT.BAT` or `SCSI.BAT`. Use `SCSI.BAT` only if you need to manually load CD-ROM drivers from floppy.

Any MS-DOS installation with CD-ROM drivers can boot the live CD, including one installed on a hard drive. Simply navigate to the `BASLIN` directory on the CD and run `BOOT.BAT` (or `SCSI.BAT`)

## USB Boot (untested)

BasicLinux shipped many USB driver modules. The MS-DOS portion of the boot stage will scan for USB CD-ROM devices (in "SCSI" mode). You can write `cdboot.ima` to a floppy, and if MS-DOS successfully detects your CD-ROM drive, then it should be possible for you to craft a driver install disk that can load the Linux USB CD-ROM drivers.

You must select Boot Option 2: "BasicLinux and load drivers from floppy" to trigger the USB device detection.

See the [SCSI documentation](#basiclinux-supported-scsi-cd-rom) and the `/driverdisk` directory for details on setting up a driver install floppy. You probably need `cdrom` (for all cdroms), `usbcore`, `usb-uhci` or `usb-ohci` or `uhci` (can just try them all), `usb-storage`, and `isofs` (if USB CD), in roughly that order.

## USB HID (keyboard + mouse)

Pass the string `usbhid` on the kernel command line.

From the LiveCD, choose "Option 3: Enter DOS Prompt" and from `Z:\BASLIN` run:

    boot usbhid

Or if you want to install additional drivers from floppy (such as SCSI or USB CD-ROM drivers):

    scsi usbhid

You can install USB HID drivers while in the LiveCD environment by calling `/usr/bin/usbhid`. You can edit `/etc/rc` to run this at boot, or you can permanently add `usbhid` to your `hdboot.bat`
