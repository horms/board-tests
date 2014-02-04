#!/bin/sh
# sdhi device driver autotest shell-script

set -e
#set -x

echo "`date`   SDHI driver autotest start"
echo "Exemple ./scrip.sh 100"

mkdir -p /mnt/sd1
mkdir -p /tmp/temp

src_dir="/mnt/sd1"
dst_dir="/tmp/temp"
data_size="$1"

# Mount src_dir and dst_dir
$(dirname $0)/../common/mount-device.sh $src_dir
$(dirname $0)/../common/mount-device.sh $dst_dir

# Make 1 stage folder
mkdir -p $src_dir/src_folder/stage1
mkdir -p $dst_dir/dst_folder/stage1

# Real src and dst folder
real_src="$src_dir/src_folder/stage1"
real_dst="$dst_dir/dst_folder/stage1"

# Write test
echo "copying $data_sizeM file from $real_src to"
echo " $real_dst "
$(dirname $0)/../common/write-common.sh \
        $real_src $real_dst 1M $data_size

# Remove write data
rm -rf $real_src/*
rm -rf $real_dst/*

# Read test
echo "copying $data_sizeM file from $real_dst to"
echo " $real_src "
$(dirname $0)/../common/write-common.sh \
	$real_dst $real_src 1M $data_size

# Remove write data
rm -rf $real_src/*
rm -rf $real_dst/*

# Umount src_dir and dst_dir
$(dirname $0)/../common/umount-device.sh $src_dir
$(dirname $0)/../common/umount-device.sh $dst_dir

rm -rf $src_dir/
rm -rf $dst_dir/
