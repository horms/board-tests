#!/bin/sh
# scifab device driver autotest shell-script
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

LOCAL_TTY="/dev/ttyUSB0"
BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
BOARD_TTY="/dev/ttySC1"
SCI_ID="1"
SIZE="10"
FILE="/tmp/sdhi-script"
SDHI="\write-read-sd0-ram.sh"
MODE="READ"

# Write a data 
if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME mount /dev/mmcblk1p1 /mnt/; then
	echo "Could not mount the device"
	exit 1
fi
if ! $(dirname $0)/../common/sdhi_read_write.py $BOARD_HOSTNAME $BOARD_USERNAME $MODE; then
	echo "Could not read a data"
	exit 1
else
	echo "Reading..."
fi

sleep 2 
if $(dirname $0)/../common/suspend-resume.py $LOCAL_TTY $BOARD_HOSTNAME $BOARD_USERNAME $BOARD_TTY $SCI_ID; then
	sleep 2
	ssh $BOARD_USERNAME@$BOARD_HOSTNAME umount /mnt/
        if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME "/usr/bin/find . -name $SDHI -print" > $FILE; then
                echo "Not found file $SDHI"
                exit 1
        fi
        for path in `cat $FILE`
        do
                echo "$path $SIZE" > $FILE
        done

        if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME < $FILE; then
                echo "can not run script $SDHI"
                exit 1
        else
                echo "SUSPEND SDHI TEST PASSED"
        fi
	sleep 1
else
	echo "FAILED"
	exit 1
fi


if [ -f $FILE ]; then
	rm $FILE
fi
