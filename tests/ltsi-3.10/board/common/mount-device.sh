#!/bin/bash
# mount devices

echo "Mount devices"

set -e
#set -x

if [ $# -ne 1 ]; then
        echo "usage: $(basename $0) PATTERN" >& 2
        exit 1
fi

DEV_DIR="$1"

# Mount device
if [ $DEV_DIR  == "/mnt/sd0" ]; then
        mount /dev/mmcblk1p1 /mnt/sd0/
elif [ $DEV_DIR == "/mnt/sd1" ]; then
        mount /dev/mmcblk2p1 /mnt/sd1/
else
        mount -t tmpfs -o size=450M tmpfs /tmp/temp/
fi

# Mount check
if [ $? -eq 0 ];then
	echo "Device have mounted"
else
	echo "Device mount is error" >&2
	exit 1
fi
