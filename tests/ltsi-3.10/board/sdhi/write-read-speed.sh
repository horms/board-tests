#!/bin/sh
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

if [ $# -ne 2 ]; then
        echo "usage: $(basename $0) DATA_SIZE CLASS_OF_CARD" >& 2
        echo "For example:$(basename $0) 50 6"
        exit 1
fi

BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
LOG_FILE="/tmp/storage.txt"
SIZE="$1"
CLASS="$2"
SOURCE="/dev/urandom"
SRC_SIZE="200"
mkdir -p /mnt/sd0
mkdir -p /tmp/temp

SD_DIR="/mnt/sd0"
RAM_DIR="/tmp/temp"

if [ $SIZE -ge 101 ]; then
        echo "Please enter a data size 100 Mb or less"
        echo "For example:$(basename $0) 50 6"
        exit 1
fi

# Make partition of storage on the Board
echo "Mount sd and ram on rootfs..."
if ! $(dirname $0)/../common/mount-device.sh $SD_DIR > /dev/null; then
	echo "Could not mount a sdcard storage"
	exit 1
fi
if ! $(dirname $0)/../common/mount-device.sh $RAM_DIR > /dev/null; then
	echo "Could not mount a tmpfs storage"
	exit 1
fi
# Make a data file on ram:
echo "Prepare a data file on ram..."
if ! $(dirname $0)/../common/read_write_data.py $SOURCE $RAM_DIR \
$SRC_SIZE $LOG_FILE; then
	echo "Prepare the data failed"
	exit 1
fi

for i in 1 2 3 
do
	`sync; echo $i > /proc/sys/vm/drop_caches`
done

if [ -f $LOG_FILE ]; then
	rm $LOG_FILE
fi
sleep 2
for perform in 1 2
do
	if [ $perform -eq 1 ]; then 
	# Write a file data:
		echo "Writing to storage..."
		data="`ls $RAM_DIR | grep "file-"`"
		SOURCE="$RAM_DIR/$data"
		if ! $(dirname $0)/../common/read_write_data.py $SOURCE $SD_DIR \
		$SIZE $LOG_FILE; then
			echo "Write failed"
		fi
        elif [ $perform -eq 2 ]; then
        # Read a file data:
		echo "Reading from storage..."
		data="`ls $SD_DIR | grep "file-$SIZE"`"
		SOURCE="$SD_DIR/$data"
                if ! $(dirname $0)/../common/read_write_data.py $SOURCE $RAM_DIR \
                $SIZE $LOG_FILE; then
                        echo "Read failed"
                fi
	fi
	for i in 1 2 3
	do
		`sync; echo $i > /proc/sys/vm/drop_caches`
	done
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
	INT=$( printf "%.0f" $SPEED )
	if [ $INT -ge $CLASS ];then
		echo "SPEED: $SPEED $UNIT : PASSED"
	else
		echo "SPEED: $SPEED $UNIT IS LOW: NOT GOOD"
	fi

	if [ -f $LOG_FILE ]; then
		rm $LOG_FILE
	fi

sleep 2
done

# Remove write data
rm -rf $SD_DIR/*
rm -rf $RAM_DIR/*

# Unload the sdcard
if $(dirname $0)/../common/umount-device.sh $SD_DIR > /dev/null; then
        echo "Board: Unloading passed"
else
        echo "Board: Unloading failed"
        exit 1
fi

sleep 2
# Umount the tmpfs
if $(dirname $0)/../common/umount-device.sh $RAM_DIR > /dev/null; then
        echo "Board: Umount tmpfs passed"
else
        echo "Board: Umount tmpfs failed"
        exit 1
fi
