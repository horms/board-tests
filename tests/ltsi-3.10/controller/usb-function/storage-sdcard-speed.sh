#!/bin/sh
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

if [ $# -ne 1 ]; then
        echo "usage: $(basename $0) DATA_SIZE" >& 2
        echo "For example:$(basename $0) 50"
        exit 1
fi

BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
LOG_FILE="/tmp/storage.txt"
SIZE="$1"
SOURCE="/dev/urandom"
DESTINATION="/media/storage"

if [ ${SIZE/.*} -ge 101 ]; then
        echo "Please enter a data size 100 Mb or less"
        echo "For example:$(basename $0) 50"
        exit 1
fi

echo "Expect 10 Mb/s up to 30 Mb/s speeds when write/read the data of 100MB or less"

# Make partition of storage on the Board
if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/mkfs.ext3 -F -L "storage" /dev/mmcblk1p1 > /dev/null 2>&1; then
	echo "Could not create a sd-card partition"
	exit 1
fi

# Load the usb storage module
if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/modprobe g_mass_storage file=/dev/mmcblk1p1 > /dev/null; then
        echo "Board: Loading passed"
else
        echo "Board: Loading failed"
        exit 1
fi

# Confirm storage have was mounted on the host PC
sleep 2 
if ! find /media -name storage > /dev/null; then
	echo "Host PC: storage mount on pc failed"
	exit 1
fi
for perform in 1 2
do
	if [ $perform -eq 1 ]; then 
	# Write a file data:
		echo "Writing to storage..."
		if ! $(dirname $0)/../common/read_write_data.py $SOURCE $DESTINATION \
		$SIZE $LOG_FILE; then
			echo "Write failed"
		fi
        elif [ $perform -eq 2 ]; then
        # Read a file data:
		echo "Reading from storage..."
		data="`ls $DESTINATION | grep file-`"
		SOURCE="$DESTINATION/$data"
		DESTINATION="/tmp"
                if ! $(dirname $0)/../common/read_write_data.py $SOURCE $DESTINATION \
                $SIZE $LOG_FILE; then
                        echo "Read failed"
                fi
	fi
	`sync; echo 3 > /proc/sys/vm/drop_caches`
	echo "Check Speed:"
	NUM=0
	PARAMETER="`cat $LOG_FILE | grep "copied"`"
	# Looking for info of Speed
	for info in $PARAMETER
	do
        	NUM=$(($NUM + 1))
        	if [ $NUM -eq 8 ]; then
                	SPEED=$info
        	elif [ $NUM -eq 9 ]; then
                	UNIT="$info"
        	fi
	done
	echo "$SPEED $UNIT"
	INT1=${SPEED/.*}
	if [ $INT1 -ge 10 ];then
		echo "SPEED: $SPEED $UNIT : PASSED"
	else
		echo "SPEED: $SPEED $UNIT IS LOW: NOT GOOD"
	fi

	if [ -f $LOG_FILE ]; then
		rm $LOG_FILE
	fi

sleep 2 
done

# Unload the usb storage module
if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/rmmod g_mass_storage > /dev/null; then
        echo "Board: Unloading passed"
else
        echo "Board: Unloading failed"
        exit 1
fi

