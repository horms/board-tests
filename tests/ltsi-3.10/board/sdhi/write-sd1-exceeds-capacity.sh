#!/bin/sh
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

if [ $# -ne 1 ]; then
        echo "usage: $(basename $0) DATA_SIZE" >& 2
        echo "For example:./$(basename $0) 10"
        exit 1
fi
#
LOG_FILE="/tmp/storage.txt"
SIZE_FILE="/tmp/size.txt"
SIZE="$1"
UNIT="mb"
FILE_NAME="/file-$SIZE$UNIT"
SOURCE="/dev/urandom"

SD_NAME="sd1"
mkdir -p /mnt/$SD_NAME
mkdir -p /tmp/temp
RAM="/tmp/temp"
SD="/mnt/$SD_NAME"

# Mount the storage of ram, sd to rootfs
echo "Mount RAM and $SD_NAME on rootfs..."
$(dirname $0)/../common/mount-device.sh $RAM
$(dirname $0)/../common/mount-device.sh $SD

echo "Please wait while program make data on RAM..."
# Make a data file on ram:
if ! $(dirname $0)/../common/read_write_data.py $SOURCE $RAM \
	$SIZE $LOG_FILE; then
	echo "Prepare the data on RAM failed"
	exit 1
fi
# To ensure that the written data has been prepared.
sync; echo 3 > /proc/sys/vm/drop_caches

COPIED_SIZE=$SIZE
TIMES=0
echo "Copying the data to $SD_NAME from RAM..."
while [ $COPIED_SIZE -ne 0 ]
do
	TIMES=$(($TIMES + 1))
	if $(dirname $0)/../common/read_write.py $RAM$FILE_NAME \
	$SD$FILE_NAME$TIMES $SIZE $LOG_FILE; then
		CONF_SIZE=`du -h $SD$FILE_NAME$TIMES`
		for size in $CONF_SIZE
		do
			echo "$size" > $SIZE_FILE
			break
		done
		if cat $SIZE_FILE | grep "K" > /dev/null || \
		   cat $SIZE_FILE | grep "M" > /dev/null || \
		   cat $SIZE_FILE | grep "G"> /dev/null;then
			COPIED_SIZE=$SIZE
		else
			COPIED_SIZE=0
		fi

		# To ensure that the written data has been prepared.
		$(dirname $0)/../common/umount-device.sh $SD > /dev/null
		# Re-mount
		$(dirname $0)/../common/mount-device.sh $SD > /dev/null
		sync; echo 3 > /proc/sys/vm/drop_caches
	else
		echo "Could not copy a data with size $SIZE"
		exit 1
	fi
done

sleep 1
if cat $LOG_FILE | grep "No space left on device" > /dev/null; then
	echo "The space on device is full"
	echo "TEST PASSED"
else
	echo "TEST FAILED"
fi

# Clean before finish work
if ! rm -r $SD/*; then
        echo "Could not remove data from $SD"
        exit 1
fi

$(dirname $0)/../common/umount-device.sh $RAM
$(dirname $0)/../common/umount-device.sh $SD

if ! rm -r $LOG_FILE; then
        echo "Could not remove $LOG_FILE"
        exit 1
fi

if ! rm -r $SIZE_FILE; then
        echo "Could not remove $SIZE_FILE"
        exit 1
fi

if ! rm -r $RAM; then
        echo "Could not remove $RAM"
        exit 1
fi

if ! rm -r $SD; then
        echo "Could not remove $SD"
        exit 1
fi
