#!/bin/sh
# usb-function device driver autotest shell-script

set -e
#set -x

# Load usb ethernet module on the Board
if ssh root@armadillo800 /sbin/modprobe g_ether > /dev/null; then
	echo "Board: Loading is OK"
else
	echo "Board: Loading is error"
	exit 1
fi

# Confirm usb ethernet device on the Board
if ssh root@armadillo800 /sbin/ifconfig -a | grep "usb0" > /dev/null; then
	echo "Board: Recognized usb ethernet device"
	ssh root@armadillo800 /sbin/ifconfig usb0 169.254.192.251 up
else
	echo "Board: did not Recognize usb ethernet device"
	exit 1
fi

# Confirm usb ethernet device on the host PC
if ifconfig -a | grep "usb0" > /dev/null; then
        echo "Host PC: Recognized usb ethernet device"
	ifconfig usb0 169.254.192.250 up
else
        echo "Host PC: did not Recognize usb ethernet device"
	exit 1
fi

# Ping between the host PC <-> the Board
# Ping the host PC -> the Board
if ping -c 3 169.254.192.251 > /dev/null; then
	echo "Ping host PC -> Board: OK"
else
	echo "Ping host PC -> Board: Error"
	exit 1
fi

# Ping the Board -> the host PC
if ssh root@armadillo800 /bin/ping -c 3 169.254.192.250 > /dev/null; then
	echo "Ping Board -> host PC: OK"
else
	echo "Ping Board -> host PC: Error"
	exit 1
fi

# Unload usb ethernet module on the Board
if ssh root@armadillo800 /sbin/rmmod  g_ether.ko > /dev/null; then
	echo "Board: Unloading is OK"
else
	echo "Board: Unloading is error"
	exit 1
fi
