@ECHO OFF
set EXPAND=YES
SET DIRCMD=/O:N
cls
path=a:\

REM assigns first found drive to Z
REM if you need to use second drive,
REM run:
REM SHSUCDX /U
REM SHSUCDX /D:oemcd001,Z,,2
REM
SHSUCDX.COM /D:oemcd001,Z,,1
DOSKEY

type image.txt

Z:
CD BASLIN

GOTO %CONFIG%

:LINUXIDE
CALL Z:\BASLIN\BOOT.BAT
GOTO QUIT

:LINUXUSB
:LINUXSCSI
CALL Z:\BASLIN\SCSI.BAT
GOTO QUIT

:DOSIDE
:DOSSCSI
:DOSUSB
echo BasicLinux 3.5 LiveCD - MS-DOS Prompt
echo You can run a custom boot command, for example:
echo loadlin zimage root=/dev/loop0 initrd=initfs.gz ro quiet
echo (you must be in the Z:\BASLIN directory)

:QUIT
