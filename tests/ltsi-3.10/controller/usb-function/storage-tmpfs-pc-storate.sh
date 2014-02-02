#!/bin/bash
# usb-function device driver autotest shell-script

set -e
#set -x

echo "Test usb-function: storage is tmpfs"
echo "Exemple ./scrip.sh root armadillo800 100"

# Make work directory on the host PC
mkdir -p /home/data/

host_user=$1
host_board=$2
data_size=$3

# Make partition of storage on the Board
ssh $host_user@$host_board /bin/mount -t tmpfs -o size=450M tmpfs /tmp
ssh $host_user@$host_board /bin/dd if=/dev/zero of=/home/tmp.img bs=1M count=400 > /dev/null 2>&1
ssh $host_user@$host_board /bin/cp /home/tmp.img /tmp/tmp.img 
ssh $host_user@$host_board /sbin/mkfs.ext3 -F -L storage /tmp/tmp.img > /dev/null 2>&1

# Load the usb storage module
if ssh $host_user@$host_board /sbin/modprobe g_mass_storage file=/tmp/tmp.img > /dev/null; then
	echo "Board: Loading is OK"
else
	echo "Board: Loading is error"
	exit 1
fi

# Confirm storage have was mountted on the host PC
sleep 2
if find /media -name storage | grep "storage" > /dev/null; then
	echo "Host PC: storage mount is OK"
else
	echo "Host PC: storage mount is error"
	exit 1
fi

src_dir="/home/data"
dst_dir="/media/storage"

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
