#!/bin/sh
# usb-function device driver autotest shell-script

set -e
#set -x

# Load usb serial module on the Board
if ssh root@armadillo800 /sbin/modprobe  g_serial > /dev/null; then
	echo "Board: Loading is OK"
else
	echo "Board: Loading is error"
	exit 1
fi

# Confirm usb serial device on the Board
if ssh root@armadillo800 /usr/bin/find /dev/ -name ttyGS0 > /dev/null; then
	echo "Board: Recognized usb serial device"
else
	echo "Board: did not Recognize usb serial device"
	exit 1
fi

# Confirm usb serial device on the host PC
if find /dev/ -name ttyACM0 > /dev/null; then
        echo "Host PC: Recognized usb serial device"
else
        echo "Host PC: did not Recognize usb serial device"
	exit 1
fi

# Unload usb serial module on the Board
if ssh root@armadillo800 /sbin/rmmod g_serial.ko > /dev/null; then
	echo "Board: Unloading is OK"
else
	echo "Board: Unloading is error"
	exit 1
fi
