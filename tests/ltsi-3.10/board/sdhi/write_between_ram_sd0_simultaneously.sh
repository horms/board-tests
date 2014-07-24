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

mkdir -p /mnt/sd0
mkdir -p /tmp/temp

RAM="/tmp/temp"
SD0="/mnt/sd0"
SD_NAME0="sd0"
RAM_NAME="ram"

# Mount the storage of ram, sd0 to rootfs
echo "Mount the devices on rootfs..."
if ! $(dirname $0)/../common/mount-device.sh $RAM > /dev/null; then
	echo "Could not mount a tmpfs storage"
	rm -rf $RAM
	exit 1
fi
if ! $(dirname $0)/../common/mount-device.sh $SD0 > /dev/null; then
	echo "Could not mount a sd0 card storage"
	rm -rf $SD0
	exit 1
fi

echo "Please wait while program make data on RAM and SD0..."
# Make a data file on ram:
if ! $(dirname $0)/../common/read_write_data.py $SOURCE $RAM $SIZE $LOG_FILE; then
	echo "Prepare the data on RAM failed"
	exit 1
fi
# Make a data file on sd0
if ! $(dirname $0)/../common/read_write_data.py $SOURCE $SD0 $SIZE $LOG_FILE; then
        echo "Prepare the data on SD0 failed"
        exit 1
fi
sync;
if [ -f $LOG_FILE ]; then
	rm -r $LOG_FILE
fi
sleep 1

echo "Writing data between RAM and SD0 simultaneously..."

if $(dirname $0)/../common/read_write_simultaneously.py $RAM$FILE_NAME \
$SD0$FILE_NAME$RAM_NAME $SD0$FILE_NAME $RAM$FILE_NAME$SD_NAME0 $SIZE ; then
        echo "Write the data between RAM and SD0 has finished"
else
	echo "Write the data between RAM and SD0 has failed"
	exit 1
fi

# To ensure that the writing data has been finished.
if ! $(dirname $0)/../common/umount-device.sh $SD0 > /dev/null; then
	echo "Could not umount the SD0 card"
	exit 1
fi
# Re-mount
if ! $(dirname $0)/../common/mount-device.sh $SD0 > /dev/null; then
	echo "Could not re-mount the SD0 card"
	exit 1
fi

echo "Confirm the copied data"

if cmp $SD0$FILE_NAME $RAM$FILE_NAME$SD_NAME0; then
	if cmp $RAM$FILE_NAME $SD0$FILE_NAME$RAM_NAME; then
		echo "TEST PASSED"
	else
		echo "TEST FAILED"
	fi
else
	echo "TEST FAILED"
fi

# Clean before finish work
if rm -r $SD0/*; then
	if ! $(dirname $0)/../common/umount-device.sh $SD0 > /dev/null; then
		echo "Could not umount the SD0 card"
		exit 1
	fi
	rm -r $SD0/
else
	echo "Could not remove data out of SD0"
fi

if rm -r $RAM/*; then
	if ! $(dirname $0)/../common/umount-device.sh $RAM > /dev/null; then
		echo "Could not umount the RAM"
		exit 1
	fi
	rm -r $RAM/
else
	echo "Could not remove data out of RAM"
fi
