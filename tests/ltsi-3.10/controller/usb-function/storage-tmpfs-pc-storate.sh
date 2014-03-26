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

if ! ssh $host_user@$host_board /bin/mount -t tmpfs -o size=400M tmpfs /tmp; then
	echo "Could not mount a ram tmpfs"
	exit 1
fi

if ! ssh $host_user@$host_board /bin/dd if=/dev/zero of=/tmp/tmp.img bs=1M count=380 \
	 > /dev/null 2>&1; then
	echo "Could not make a tmp.img file"
	exit 1
fi

if ! ssh $host_user@$host_board /sbin/mkfs.ext3 -F -L "storage" /tmp/tmp.img > \
	/dev/null 2>&1; then
	echo "Could not create a partition"
	exit 1
fi

# Load the usb storage module
if ssh $host_user@$host_board /sbin/modprobe g_mass_storage file=/tmp/tmp.img > /dev/null; then
	echo "Board: Loading passed"
else
	echo "Board: Loading failed"
	exit 1
fi

# Confirm storage have was mountted on the host PC
sleep 2
if find /media -name storage | grep "storage" > /dev/null; then
	echo "Host PC: The storage has mounted on pc "
else
	echo "Host PC: The storage hasn't mounted on pc"
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
if ssh $host_user@$host_board /sbin/rmmod g_mass_storage > /dev/null; then
        echo "Board: Unloading passed"
else
        echo "Board: Unloading failed"
        exit 1
fi
sleep 1
# Umount the tmpfs storage
if ssh $host_user@$host_board /bin/umount /tmp > /dev/null; then
        echo "Board: Umount tmpfs: passed"
else
        echo "Board: Umount tmpfs: failed"
        exit 1
fi

