#!/bin/sh
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

if [ $# -ne 2 ]; then
	echo "usage: $(basename $0) DATA_SIZE HOW_MANY_TIMES" >& 2
	echo "For example:./$(basename $0) 10 20"
	exit 1
fi

LOG_FILE="/tmp/storage.txt"
SIZE="$1"
TIMES="$2"
UNIT="mb"
FILE_NAME="/file-$SIZE$UNIT"
SOURCE="/dev/urandom"

mkdir -p /mnt/sd0
mkdir -p /mnt/sd1

SD0="/mnt/sd0"
SD1="/mnt/sd1"
SD_NAME0="sd0"
SD_NAME1="sd1"
OK=0
NG=0

# Mount SD0, SD1 on rootfs. 
echo "Mount the devices on rootfs..."
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

sync; echo 3 > /proc/sys/vm/drop_caches

if [ -f $LOG_FILE ]; then
	rm -r $LOG_FILE
fi
sleep 2

echo "Writing/Reading data between SD0 and SD1 simultaneously..."
for TEST in $(seq 1 $TIMES)
do
	if [ $TEST -eq 1 ];then
		echo "Test for $TEST time:"
	else
		echo "Test for $TEST times:" 
	fi
	if ! $(dirname $0)/../common/read_write_simultaneously.py $SD0$FILE_NAME \
	$SD1$FILE_NAME$SD_NAME0 $SD1$FILE_NAME $SD0$FILE_NAME$SD_NAME1 $SIZE ; then
		echo "Write/read the data between SD0 and SD1 has failed"
		exit 1
	fi
	if cmp $SD1$FILE_NAME $SD0$FILE_NAME$SD_NAME1; then
		if cmp $SD0$FILE_NAME $SD1$FILE_NAME$SD_NAME0; then
			echo "PASSED"
			OK=$(($OK + 1))
		else
			echo "FAILED"
			NG=$(($NG + 1))
		fi
	else
		echo "TEST FAILED"
	fi
	rm -rf $SD0$FILE_NAME$SD_NAME1
	rm -rf $SD1$FILE_NAME$SD_NAME0
sleep 1
done
echo "PASSED:$OK, FAILED:$NG"

# Clean before finish work
umount $SD0/
umount $SD1/
rm -r /mnt/*
