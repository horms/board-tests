#!/bin/bash
# usb-function device driver autotest shell-script

set -e
#set -x

echo "Test usb-function: storage is sd card"
echo "Exemple ./scrip.sh root armadillo800 100"

# Make work directory on the host PC
mkdir -p /home/data/

host_user=$1
host_board=$2
data_size=$3

# Make partition of storage on the Board
# Check sd card
if ssh $host_user@$host_board /bin/dmesg | grep "mmcblk1" > /dev/null; then
	echo "Board: insertted the sd card"
	ssh $host_user@$host_board /sbin/mkfs.ext3 -L storage /dev/mmcblk1p1 > /dev/null 2>&1
else
	echo "Board: did not insert the sd card"
	exit 1
fi

# Load the usb storage module
if ssh $host_user@$host_board /sbin/modprobe g_mass_storage file=/dev/mmcblk1p1 > /dev/null; then
	echo "Board: Loading is OK"
else
	echo "Board: Loading is error"
	exit 1
fi

# Confirm storage have was mountted on the host PC
sleep 8
if find /media -name storage | grep "storage" > /dev/null; then
	echo "Host PC: storage mount is OK"
else
	echo "Host PC: storage mount is error"
	exit 1
fi

src_dir="/media/storage"
dst_dir="/home/data"

# write test
echo "copying ${answer}M file from $src_dir to $dst_dir "
$(dirname $0)/../../board/common/write-common.sh \
        $src_dir $dst_dir 1M $data_size

rm -rf $src_dir/*
rm -rf $dst_dir/*

# Umount storage on the host PC
umount /media/storage

# Unload storage module on the Board
if ssh $host_user@$host_board /sbin/rmmod g_mass_storage.ko > /dev/null; then
        echo "Board: Unloading is OK"
else
        echo "Board: Unloading is error"
        exit 1
fi
