#!/bin/sh
# usb-function device driver autotest shell-script

set -e
#set -x

BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
LOG_FILE="/tmp/text.txt"
CLIENT="BOARD"
MESG="Hello!, How are you?"
# Load usb serial module on the Board
if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/modprobe g_serial > /dev/null; then
	echo "Board: Loading is OK"
else
	echo "Board: Loading is error"
	exit 1
fi

sleep 2 

INTERFACE="ttyGS"
echo "Confirm $INTERFACE interface on board:"
for id in $(seq 0 10);
do
        IF1="$INTERFACE$id"
        if ssh $BOARD_USERNAME@$BOARD_HOSTNAME ls /dev/ | grep "$IF1" > /dev/null; then
                echo "$IF1."
                echo "Board: Recognized $IF1 usb serial device"
                break
        fi
done

if [ $id -eq 10 ]; then
        echo "Has no $INTERFACE interface!"
        exit 1
fi

echo "Please connect Board and PC with a usb-function cable"
sleep 5 
INTERFACE="ttyACM"
echo "Confirm $INTERFACE interface on PC:"
for id in $(seq 0 10);
do
        IF2="$INTERFACE$id"
        if ls /dev/ | grep "$IF2" > /dev/null; then
                echo "$IF2."
		echo "Host PC: Recognized $IF2 usb serial device"
                break
        fi
done

if [ $id -eq 10 ]; then
        echo "Has no $INTERFACE interface!"
        exit 1
fi

echo "From PC to Board:"
if $(dirname $0)/../common/usb_func_serial_to_board.py $BOARD_HOSTNAME \
$BOARD_USERNAME $LOG_FILE $IF1; then 
	sleep 2
	if `echo $MESG > /dev/$IF2`; then
		echo "Sending a message..."
	else
		echo "Could not send a message"
		exit 1
	fi
else
	exit 1
fi

if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /bin/cat $LOG_FILE | grep "$MESG"; then
	echo "Send a message from PC to board passed"
else
	echo "Send a message from PC to board failed"
	exit 1
fi

echo "From Board to PC:"

if $(dirname $0)/../common/usb_func_serial_to_pc.py $BOARD_HOSTNAME $BOARD_USERNAME $IF2 $IF1; then
	echo "Send a message from board to PC passed"
else
       echo "Send a message from board to PC failed"
       exit 1
fi

# Unload usb serial module on the Board
if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/rmmod  g_serial > /dev/null; then
	echo "Board: Unloading is OK"
else
	echo "Board: Unloading is error"
	exit 1
fi

