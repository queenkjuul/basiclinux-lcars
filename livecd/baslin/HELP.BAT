echo BOOT.BAT: run standard CD-ROM liveCD boot (uses initfs.gz)
echo SCSI.BAT: run CD-ROM liveCD boot but ask for driver floppy before init (uses scsifs.gz)
echo HDBOOT.BAT: run standard boot from MS-DOS partition (FS.IMG) (uses hdfs.gz)
echo E2BOOT.BAT: modify with your Ext2 root partition to boot it (boots root partition directly, no initrd)
echo
echo PARAMETERS:
echo All boot scripts accept kernel parameters to control init
echo usbhid - install USB HID (Mouse/KB) drivers
echo usbstor - install USB Storage drivers
echo swapoff - do not search for or activate swapfiles at boot
echo norootverify - do not check root filesystem at boot
echo ide-cd - install IDE CD-ROM drivers at boot
echo
echo Example:
echo     hdboot.bat usbhid usbstor ide-cd
echo