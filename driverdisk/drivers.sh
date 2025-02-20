#!/bin/sh

# Script to load SCSI drivers for CD-ROM, called from initrd
# only a few commands are available this early in the boot:
#
#   echo insmod losetup ls mount sleep test unmount

echo "Loading drivers for Adaptec AHA-1542..."

# all paths must be absolute

# all SCSI cards require scsi_mod
insmod /floppy/scsi_mod.o
# all SCSI CD-ROMs require sr_mod
insmod /floppy/sr_mod.o
# card-specific driver (see /modules on the liveCD)
# ensure you pass the right options for your driver
insmod /floppy/aha1542.o 0x334,10,7

# The stock boot script scans the following block devices:
#   hda hdb hdc hdd sda sdb sdc sdd sr0
# it does not look for partitions on block devices (i.e. only CD-ROMs)
# if your driver uses a different block device or partition, mount it on DOS here
# For example:
#   mount -t msdos /dev/sda1 /DOS