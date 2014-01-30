#!/bin/sh
# usb-function device driver autotest shell-script

set -e
#set -x

# Load usb serial module on the Board
if ssh root@armadillo800 /sbin/modprobe g_serial > /dev/null; then
	echo "Board: Loading is OK"
else
	echo "Board: Loading is error"
	exit 1
fi

# Tranfer data between the Board <-> the host PC
LOCAL_TTY="/dev/ttyS0"
BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
BOARD_TTY=" /dev/ttyGS0"

# Run tty-ping.py to connect Host PC with the Board
$(dirname $0)/../common/tty-ping.py $LOCAL_TTY $BOARD_HOSTNAME $BOARD_USERNAME $BOARD_TTY

# Unload usb serial module on the Board
if ssh root@armadillo800 /sbin/rmmod g_serial.ko > /dev/null; then
	echo "Board: Unloading is OK"
else
	echo "Board: Unloading is error"
	exit 1
fi
