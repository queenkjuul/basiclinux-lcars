@ECHO OFF
set EXPAND=YES
SET DIRCMD=/O:N
cls
path=a:\

REM assigns first found to W, going up to Z (Linux will only check first 4 disks anyway)
REM
SHSUCDX.COM /D:oemcd001 /L:W
DOSKEY

type image.txt

REM I swear I'm not an idiot, DOS for loops are just real stupid

SET DRIVE=
DREADY W
IF ERRORLEVEL 0 IF NOT ERRORLEVEL 1 SET DRIVE=W
DREADY X
IF ERRORLEVEL 0 IF NOT ERRORLEVEL 1 SET DRIVE=X
DREADY Y
IF ERRORLEVEL 0 IF NOT ERRORLEVEL 1 SET DRIVE=Y
DREADY Z
IF ERRORLEVEL 0 IF NOT ERRORLEVEL 1 SET DRIVE=Z

FOR %%G IN (W X Y Z) DO IF %%G == %DRIVE% IF EXIST %%G:\BASLIN\BOOT.BAT GOTO CONTINUE

REM this next line gets skipped if we found boot script
GOTO QUIT

:CONTINUE
%DRIVE%:
CD %DRIVE%:\BASLIN

GOTO %CONFIG%

:LINUXIDE
CALL BOOT.BAT
GOTO QUIT

:LINUXUSB
:LINUXSCSI
CALL SCSI.BAT
GOTO QUIT

:DOSIDE
:DOSSCSI
:DOSUSB
echo                 -=BasicLinux-LCARS 3.5.1 LiveCD - MS-DOS Prompt=-
echo.
echo You can run a custom boot command, for example:
echo   loadlin zimage root=/dev/loop0 initrd=initfs.gz ro quiet
echo or pass arguments to the standard boot, for example:
echo   boot usbhid norootverify
echo or
echo   scsi lowmem quiet
echo (you must be in the %DRIVE%:\BASLIN directory)
echo.

:QUIT
