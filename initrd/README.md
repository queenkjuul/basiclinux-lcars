# Initial RAMDISKs for BasicLinux-LCARS

Modified from their original versions.

## contents

## compressed ramdisks

`*.GZ`: actual files as used on the CD images

## raw ramdisks

All of these are raw ext2 revision 0 disk images, 300K in size (could probably shrink a dozen K or so, should probably re-generate them but it's kind of a pain)

`initrd.img`: the LiveCD initrd image; loads IDE-CD drivers and searches `/dev/hda - /dev/hdd` for the LiveCD image. Called by `BOOT.BAT` Gzips into `INITFS.GZ`

`initrd.scsi.img`: SCSI/USB initrd image; pauses init to search the floppy drive for a `drivers.sh` script which handles SCSI/USB module insertion. If the `drivers.sh` script doesn't mount the CD at `/DOS`, then the `linuxrc` script will search `/dev/hda-hdd`, `/dev/sda-sdd`, and `/dev/sr0` for the image and proceed if it is found. Called by `SCSI.BAT`. Gzips into `SCSIFS.GZ`

`HDFS`: initrd image for use when baslin is installed to an MS-DOS partition (C:\BASLIN). Called by `HDBOOT.BAT`. Gzips into `HDFS.GZ`

## ramdisk filesystems

The directories `HDFS~`, `initrd`, and `initrd.scsi` represent extractions from the above filesystem images. Because they contain special device nodes, you probably can't just directly roll the directories into a new ext2fs if you're trying to create a new initrd. Instead, you'd need to mount the old image and your new image, and copy at least `/dev/*` over to the new one before proceeding.

## busybox

the initrd images use an even-more-stripped-down version of Busybox, built using uclibc (because the original BasicLinux version did not include `insmod` and thus could not load CD drivers).

See the [wiki page on customization](/wiki/Customization)
