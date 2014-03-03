#!/bin/sh
# Usb-function device driver autotest shell-script
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

LOCAL_TTY="/dev/ttyUSB0"
BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
BOARD_TTY="/dev/ttySC1"
SCI_ID="1"
SIZE="100"

# Load usb serial module on the Board
if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/modprobe g_serial > /dev/null; then
        echo "Board: Loading is OK"
else
        echo "Board: Loading is error"
        exit 1
fi

sleep 2

# Run suspend-resume.py to connect Host PC with the Board
if ! $(dirname $0)/../common/suspend-resume.py $LOCAL_TTY $BOARD_HOSTNAME $BOARD_USERNAME \
	$BOARD_TTY $SCI_ID; then
	echo "SUSPEND FAILED"
	exit 1
fi

# Unload usb serial module on the Board
if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/rmmod  g_serial > /dev/null; then
        echo "Board: Unloading is OK"
else
        echo "Board: Unloading is error"
        exit 1
fi

if ! $(dirname $0)/../usb-function/serial-function_345.sh;then
	echo "TEST FAILED"
else 
	echo "TEST PASSED"
fi

