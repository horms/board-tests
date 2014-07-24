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
mkdir -p /mnt/sd1
mkdir -p /tmp/temp

RAM="/tmp/temp"
SD0="/mnt/sd0"
SD1="/mnt/sd1"
SD_NAME0="sd0"
SD_NAME1="sd1"

# Mount RAM, SD0, SD1 on rootfs. 
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
if ! $(dirname $0)/../common/mount-device.sh $SD1 > /dev/null; then
        echo "Could not mount a sd1 card storage"
	rm -rf $SD1
        exit 1
fi

# Make data on SD0 SD1
echo "Please wait while program make data on SD0 SD1..."
if ! $(dirname $0)/../common/read_write_data.py $SOURCE $SD0 $SIZE $LOG_FILE; then
	echo "Prepare the data on SD0 failed"
	exit 1
fi

if ! $(dirname $0)/../common/read_write_data.py $SOURCE $SD1 $SIZE $LOG_FILE; then
        echo "Prepare the data on SD1 failed"
        exit 1
fi
sync;
if [ -f $LOG_FILE ]; then
	rm -r $LOG_FILE
fi
sleep 1
echo "Writing data from SD0, SD1 to RAM simultaneously..."

if $(dirname $0)/../common/read_write_simultaneously.py $SD0$FILE_NAME \
$RAM$FILE_NAME$SD_NAME0 $SD1$FILE_NAME $RAM$FILE_NAME$SD_NAME1 $SIZE ; then
        echo "Write the data to SD0 and SD1 has finished"
else
	echo "Write the data to SD0 and SD1 has failed"
	exit 1
fi

# To ensure that the writing data has been finished.
if ! $(dirname $0)/../common/umount-device.sh $SD0 > /dev/null; then
	echo "Could not umount the SD0 card"
	exit 1
fi

if ! $(dirname $0)/../common/umount-device.sh $SD1 > /dev/null; then
	echo "Could not umount the SD1 card"
	exit 1
fi

# Re-mount
if ! $(dirname $0)/../common/mount-device.sh $SD0 > /dev/null; then
	echo "Could not re-mount the SD0 card"
	exit 1
fi

if ! $(dirname $0)/../common/mount-device.sh $SD1 > /dev/null; then
	echo "Could not re-mount the SD1 card"
	exit 1
fi

echo "Confirm the copied data"

if cmp $SD1$FILE_NAME $RAM$FILE_NAME$SD_NAME1; then
	if cmp $SD0$FILE_NAME $RAM$FILE_NAME$SD_NAME0; then
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
	exit 1
fi

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
