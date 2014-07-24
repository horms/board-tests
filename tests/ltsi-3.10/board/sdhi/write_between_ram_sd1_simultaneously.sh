#!/bin/sh
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

if [ $# -ne 1 ]; then
        echo "usage: $(basename $0) DATA_SIZE" >& 2
        echo "For example:./$(basename $0) 200"
        exit 1
fi

LOG_FILE="/tmp/storage.txt"
SIZE="$1"
UNIT="mb"
FILE_NAME="/file-$SIZE$UNIT"
SOURCE="/dev/urandom"

mkdir -p /mnt/sd1
mkdir -p /tmp/temp

RAM="/tmp/temp"
SD1="/mnt/sd1"
SD_NAME1="sd1"
RAM_NAME="ram"

# Mount the storage of ram, sd1 to rootfs
echo "Mount the devices on rootfs..."
if ! $(dirname $0)/../common/mount-device.sh $RAM > /dev/null; then
	echo "Could not mount a tmpfs storage"
	rm -rf $RAM
	exit 1
fi
if ! $(dirname $0)/../common/mount-device.sh $SD1 > /dev/null; then
	echo "Could not mount a sd1 card storage"
	rm -rf $SD1
	exit 1
fi

# Make a data file on ram and sd1:
echo "Please wait while program make data on RAM and SD1..."
if ! $(dirname $0)/../common/read_write_data.py $SOURCE $RAM $SIZE $LOG_FILE; then
	echo "Prepare the data on RAM failed"
	exit 1
fi
# Make a data file on sd1
if ! $(dirname $0)/../common/read_write_data.py $SOURCE $SD1 $SIZE $LOG_FILE; then
        echo "Prepare the data on SD1 failed"
        exit 1
fi

sync; echo 3 > /proc/sys/vm/drop_caches

if [ -f $LOG_FILE ]; then
	rm -r $LOG_FILE
fi
sleep 1

echo "Writing data between RAM and SD1 simultaneously..."

if $(dirname $0)/../common/read_write_simultaneously.py $RAM$FILE_NAME \
$SD1$FILE_NAME$RAM_NAME $SD1$FILE_NAME $RAM$FILE_NAME$SD_NAME1 $SIZE ; then
        echo "Write the data between RAM and SD1 has finished"
else
	echo "Write the data between RAM and SD1 has failed"
	exit 1
fi

# To ensure that the writing data has been finished.
if ! $(dirname $0)/../common/umount-device.sh $SD1 > /dev/null; then
	echo "Could not umount the SD1 card"
	exit 1
fi
# Re-mount
if ! $(dirname $0)/../common/mount-device.sh $SD1 > /dev/null; then
	echo "Could not re-mount the SD1 card"
	exit 1
fi

echo "Confirm the copied data"

if cmp $SD1$FILE_NAME $RAM$FILE_NAME$SD_NAME1; then
	if cmp $RAM$FILE_NAME $SD1$FILE_NAME$RAM_NAME; then
		echo "TEST PASSED"
	else
		echo "TEST FAILED"
	fi
else
	echo "TEST FAILED"
fi

# Clean before finish work
if rm -r $SD1/*; then
	if ! $(dirname $0)/../common/umount-device.sh $SD1 > /dev/null; then
		echo "Could not umount the SD1 card"
		exit 1
	fi
	rm -r $SD1/
else
	echo "Could not remove data out of SD1"
	exit 1
fi

if rm -r $RAM/*; then
	if ! $(dirname $0)/../common/umount-device.sh $RAM > /dev/null; then
		echo "Could not umount the RAM"
		exit 1
	fi
	rm -r $RAM/
else
	echo "Could not remove data out of RAM"
	exit 1
fi
