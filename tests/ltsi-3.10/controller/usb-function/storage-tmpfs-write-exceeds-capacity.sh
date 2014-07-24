#!/bin/sh
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

if [ $# -ne 1 ]; then
        echo "usage: $(basename $0) DATA_SIZE" >& 2
        echo "For example:$(basename $0) 500"
        exit 1
fi

BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
LOG_FILE="/tmp/storage.txt"
SIZE="$1"
SOURCE="/dev/urandom"
DESTINATION="/media/storage"

if [ $(printf "%.0f" $SIZE) -le 399 ]; then
	echo "Please enter a data size 400 Mb or more"
	echo "For example:$(basename $0) 500"
	exit 1
fi

# Make partition of storage on the Board
if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME /bin/mount -t tmpfs -o size=400M tmpfs /tmp; then
	echo "Could not mount a tmpfs storage"
	exit 1
fi

if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME /bin/dd if=/dev/zero of=/tmp/tmp.img bs=1M count=350 > /dev/null 2>&1; then
	echo "Could not make a tmpfs storage"
	exit 1
fi

if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/mkfs.ext3 -F -L "storage" /tmp/tmp.img > /dev/null 2>&1; then
	echo "Could not create a tmpfs partition"
	exit 1
fi

# Load the usb storage module
if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/modprobe g_mass_storage file=/tmp/tmp.img > /dev/null; then
        echo "Board: Loading passed"
else
        echo "Board: Loading failed"
        exit 1
fi

# Confirm storage have was mounted on the host PC
sleep 5
if ! find /media -name storage > /dev/null; then
	echo "Host PC: storage mount on pc failed"
	exit 1
fi

#write a file data:
echo "Writing to storage..."
if ! $(dirname $0)/../common/read_write_data.py $SOURCE $DESTINATION \
	$SIZE $LOG_FILE; then
	echo "Write failed"
else
	echo 3 > /proc/sys/vm/drop_caches
fi
if cat $LOG_FILE | grep "No space left on device" > /dev/null; then
	echo "The data has written over capacity of storage"
	echo "TEST PASSED"
else
	echo "The data hasn't written over capacity of storage"
	echo "TEST FAILED"
fi

	if [ -f $LOG_FILE ]; then
		rm $LOG_FILE
	fi

# Unload the usb storage module
if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /sbin/rmmod g_mass_storage > /dev/null; then
        echo "Board: Unloading passed"
else
        echo "Board: Unloading failed"
        exit 1
fi

sleep 2
# Umount the tmpfs storage
if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /bin/umount /tmp > /dev/null; then
        echo "Board: Umount tmpfs passed"
else
        echo "Board: Umount tmpfs failed"
        exit 1
fi

