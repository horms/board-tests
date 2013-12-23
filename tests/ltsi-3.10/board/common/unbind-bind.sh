#!/bin/sh
# unbind-bind-write.sh
#
# Simple test of binding and unbinding a device
# 
# Copyright (C) 2013 Horms Soltutions Ltd.
#
# Contact: Simon Horman <horms@verge.net.au>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.

set -e
#set -x

if [ $# -lt 2 ]; then
	echo "usage: $(basename $0) DRIVER DEVICE_NAME [CHECK_PATH...]" >& 2
	exit 1
fi

DRIVER="$1"; shift
DEVICE_NAME="$1"; shift

SYSFS_BASE_DIR="/sys/bus/platform/drivers/$DRIVER"
SYSFS_DEV_DIR="$SYSFS_BASE_DIR/$DEVICE_NAME"

CHECK_PATH="$SYSFS_DEV_DIR $@"

exists ()
{
	for i in $CHECK_PATH; do
		if [ ! -e "$i" ]; then
        		echo \'$i\': No such file or directory >&2
        		exit 1
		fi
	done
}

echo "Test device files exists"
exists()

echo "Unbind device"
echo "$DEVICE_NAME" > "$SYSFS_BASE_DIR/unbind"

echo "Test that block device and sysfs directory no longer exist"
for i in $CHECK_PATH; do
	if [ -e "$i" ]; then
		echo Failed to unbind \'$DEVICE_NAME\': \'$i\' still exists >&2
		exit 1
	fi
done

echo "Bind device"
echo "$DEVICE_NAME" > "$SYSFS_BASE_DIR/bind"

echo "Wait for device files to be recreated"
for i in $(seq 1 32); do
	OK="true"
	for i in $CHECK_PATH; do
		if [ ! -e "$i" ]; then
			OK="false"
			break
		fi
	done
	if [ "$OK" = "false" ]; then
		sleep 0.1
	else 
		break
	fi
done

echo "Test that device files once again exist"
exists

