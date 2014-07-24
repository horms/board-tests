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
for TEST in $(seq 1 $TIMES)
do
	if [ $TEST -eq 1 ];then
		echo "Test for $TEST time:"
	else
		echo "Test for $TEST times:" 
	fi

	#Make data on SD0 and SD1
	echo "Please wait while program make data on SD0 SD1..."
	if ! $(dirname $0)/../common/read_write_data.py $SOURCE $SD0 $SIZE $LOG_FILE; then
		echo "Prepare the data on SD0 failed"
		exit 1
	fi

	if ! $(dirname $0)/../common/read_write_data.py $SOURCE $SD1 $SIZE $LOG_FILE; then
		echo "Prepare the data on SD1 failed"
		exit 1
	fi
	
	#Change name file data
	FILE_NAME0="/file$TEST-$SIZE""mb"
	FILE_NAME1="/file$TEST-$SIZE""mb"
	mv "$SD0/file-$SIZE""mb" "$SD0/file$TEST-$SIZE""mb"
	mv "$SD1/file-$SIZE""mb" "$SD1/file$TEST-$SIZE""mb"

	#Delete cache memory
	sync;

	#Delete LOG_FILE
	if [ -f $LOG_FILE ]; then
		rm -r $LOG_FILE
	fi
	sleep 1

	#Write/Read data SD0, SD1
	echo "Writing/Reading data between SD0 and SD1 simultaneously..."
	if ! $(dirname $0)/../common/read_write_simultaneously.py $SD0$FILE_NAME0 \
	$SD1$FILE_NAME0 $SD1$FILE_NAME1 $SD0$FILE_NAME1 $SIZE ; then
		echo "Write/read the data between SD0 and SD1 has failed"
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

	if cmp $SD1$FILE_NAME1 $SD0$FILE_NAME1; then
		if cmp $SD0$FILE_NAME0 $SD1$FILE_NAME0; then
			echo "PASSED"
			OK=$(($OK + 1))
		else
			echo "FAILED"
			NG=$(($NG + 1))
		fi
	else
		echo "TEST FAILED"
	fi
done

echo "TEST PASSED:$OK, TEST FAILED:$NG"

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
