#/bin/sh!
##Part of this is a script, part instructions.

##Download BL3 passwd.tgz and pkg passwd.tgz
##Run the new /bin/adduser to add a user and password.
##Example:  'add user linux', then select a password.
##Weak passwords do not mix characters and numerals, but work.

##cp -a /root/* /home/user  (substitute actual user for 'user')
##cp -a /root/.* /home/user    " " 
## cd /home/user               " "
##chown -R user *              " "
##chown -R user .*             " "

##May not be needed.  BL3 has no chgrp.
##chgrp -R users *
##chgrp -R users .*

##lynx.cfg can be set to download to this directory.  
mkdir /download
chmod o+rw /download

##Edit /etc/profile to remove this line:
# export HOME=/root

##Edit /etc/rc as follows:
# Remove the # before insmod slhc and insmod ppp (so user can dial)
# For a network, insert required modules and run ifconfig or udhcpc.
# Same if user wants to access the CD-ROM drive.  But a newbie
# probably won't know how to mount it.
# chmod o+rw /dev/?ty*  # these devices are used by pppd, rxvt, ssh
# rm -r /tmp/lynx*  #to prevent old files accumulating

#Change permissions as follows:
mknod /dev/urandom c 1 9  #missing from BL3, not needed by dbclient?
chmod o+w /dev/urandom #needed by ssh to avoid 'PRNG is not seeded'
chmod o+w /dev/null  #needed by Opera
chmod o+w /tmp      #needed by lynx

#Allow user access to scripts not on the path:
ln -sf /usr/sbin/ppp-on /usr/bin/ppp-on
ln -sf /usr/sbin/ppp-off /usr/bin/ppp-off
##Similarly for anything else in /usr/sbin to be used by user.
##Or put /usr/sbin on the path for user, or symlink to /usr/bin.

chmod +s eznet  #allows eznet to access pppd
chmod +s Xvesa  #for a standard X server use Xwrapper and Xwrapper.config