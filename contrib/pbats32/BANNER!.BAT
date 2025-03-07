@echo off
logecho $V | nset M!=$1
count M!
echo Sunday Monday Tuesday Wednesday Thursday Friday Saturday |nset M!=$%M!%
logecho %M!%, $N $D, $C$Y | nset M!=$0
banner /m3/c44 /p %M!% - $T ***
set M!=
