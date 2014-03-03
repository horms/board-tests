#!/bin/sh
# usb-function device driver autotest shell-script

set -e
#set -x

BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
INTERFACE="usb"
BOARD_IP="169.254.192.251"
HOSTPC_IP="169.254.192.250"

# Load usb ethernet module on the Board
if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/modprobe g_ether > /dev/null; then
        echo "Board: Loading is OK"
else
        echo "Board: Loading is error"
        exit 1
fi

sleep 5 

for id in $(seq 0 10);
do
        BIF="$INTERFACE$id"
        if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/ifconfig -a | grep "$BIF" > /dev/null; then
                echo "Board: Recognized $BIF ethernet device"
                break
        fi
done

if [ $id -eq 10 ]; then
        echo "Has no $INTERFACE interface!"
        exit 1
fi
echo "Please connect Board and PC with a usb-function cable"

for id in $(seq 0 10);
do
        PCIF="$INTERFACE$id"
        if ifconfig -a | grep "$PCIF" > /dev/null; then
                echo "Host PC: Recognized $PCIF ethernet device"
                break
        fi
done

if [ $id -eq 10 ]; then
        echo "Has no $INTERFACE interface!"
        exit 1
fi

# Confirm usb ethernet device on the Board
if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/ifconfig $BIF $BOARD_IP up; then
	echo "Set ip $BOARD_IP failed"
	exit 1
fi

# Confirm usb ethernet device on the host PC
if ! ifconfig $PCIF $HOSTPC_IP up; then
	echo "Set ip $HOSTPC_IP failed"
	exit 1
fi

sleep 5
# Ping between the host PC <-> the Board

# Ping the host PC -> the Board
if ping -c 3 $BOARD_IP > /dev/null; then
	echo "Ping host PC -> Board: OK"
else
	echo "Ping host PC -> Board: Error"
	exit 1
fi

# Ping the Board -> the host PC
if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /bin/ping -c 3 $HOSTPC_IP > /dev/null; then
	echo "Ping Board -> host PC: OK"
else
	echo "Ping Board -> host PC: Error"
	exit 1
fi

# Unload usb ethernet module on the Board
if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/rmmod  g_ether.ko > /dev/null; then
	echo "Board: Unloading is OK"
else
	echo "Board: Unloading is error"
	exit 1
fi
