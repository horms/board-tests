#!/bin/sh
# scifab device driver autotest shell-script
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

if [ $# -ne 2 ]; then
        echo "usage: $(basename $0) HOST_IP_ADDR BOARD_IP_ADDR" >& 2
        echo "For example: $(basename $0) 172.16.1.9 172.16.1.36"
        exit 1
fi

LOCAL_TTY="/dev/ttyUSB0"
BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
BOARD_TTY="/dev/ttySC1"
SCI_ID="1"
HOSTPC_IP="$1"
BOARD_IP="$2"
FILE="/tmp/ping-script"
PING="\ping-local-LAN.sh"

if $(dirname $0)/../common/ping.py $BOARD_IP; then
	echo "Pinging to $BOARD_IP ..."
	# Run suspend-resume.py to connect Host PC with the Board
	if $(dirname $0)/../common/suspend-resume.py $LOCAL_TTY $BOARD_HOSTNAME $BOARD_USERNAME $BOARD_TTY $SCI_ID; then
		sleep 1
	        if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME "/usr/bin/find . -name $PING -print" > $FILE; then
                	echo "Not found file $PING"
                	exit 1
		fi
        	for path in `cat $FILE`
        	do
                	echo "$path $HOSTPC_IP $BOARD_IP" > $FILE
        	done

        	if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME < $FILE; then
                	echo "can not run script $PING"
                	exit 1
        	else
                	echo "SUSPEND SDHI TEST PASSED"
        	fi

        	if [ -f $FILE ]; then
                	rm $FILE
        	fi
	else
		exit 1
	fi
else
	echo "Could not ping to $BOARD_IP address"
fi
