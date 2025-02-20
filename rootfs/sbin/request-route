#! /bin/sh
LOCK=/tmp/request-route
PATH=/usr/sbin:$PATH	# for ppp-2.2*
export PATH

# Note: you are _not_ forced to use ppp!
# You can do whatever you want in order to satisfy the kernel route request.
# It might be a good idea to set up the route as the default route, in case
# you are using e.g. slip or plip or any other net driver...

#
# This script will be called from kerneld with the requested route as $1
# Create a chat script for your nameserver (as defined in /etc/resolv.conf)
#

chatfile=/etc/ppp/chat.$1

if [ -f $chatfile ]
then
	#
	# Tune your favourite parameters to pppd, including the idle-disconnect option.
	# Kerneld will be automatically triggered to load slhc.o and ppp.o
	#
	pppd connect "chat -f $chatfile" /dev/modem 38400 \
	     idle-disconnect 600 modem defaultroute noipdefault \
	     &  # let pppd detach itself whenever it wants to...

	#
	# Timer to be killed by ip-up, tunable! Check kerneld delay as well
	#
	sleep 60 &
	sleepid=$!
	echo $sleepid > $LOCK
	wait $sleepid
	rm -f $LOCK
	exit 0
else
	exit 1
fi
