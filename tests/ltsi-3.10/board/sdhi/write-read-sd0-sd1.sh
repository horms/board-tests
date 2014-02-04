#!/bin/sh
# sdhi device driver autotest shell-script

set -e
#set -x

echo "`date`   SDHI driver autotest start"
echo "Exemple ./scrip.sh 100"

mkdir -p /mnt/sd0
mkdir -p /mnt/sd1

src_dir="/mnt/sd0"
dst_dir="/mnt/sd1"
data_size="$1"

# Mount src_dir and dst_dir
$(dirname $0)/../common/mount-device.sh $src_dir
$(dirname $0)/../common/mount-device.sh $dst_dir

# write test
echo "Copying $1M file from $src_dir to $dst_dir "
$(dirname $0)/../common/write-common.sh \
        $src_dir $dst_dir 1M $data_size

# Remove write data
rm -rf $src_dir/*
rm -rf $dst_dir/*

# Read test
echo "Copying $1M file from $dst_dir to $src_dir"
$(dirname $0)/../common/write-common.sh \
	$dst_dir $src_dir 1M $data_size

# Remove write data
rm -rf $src_dir/*
rm -rf $dst_dir/*

# Umount src_dir and dst_dir
$(dirname $0)/../common/umount-device.sh $src_dir
$(dirname $0)/../common/umount-device.sh $dst_dir

rm -rf $src_dir/
rm -rf $dst_dir/
