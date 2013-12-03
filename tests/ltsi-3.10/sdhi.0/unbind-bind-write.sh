#!/bin/sh

set -e
#set -x

echo "SDHI unbind/bind/write test"

if [ $# -ne 0 ]; then
	echo "usage: $(basename $0)" >& 2
	exit 1
fi

DRIVER="sh_mobile_sdhi"
DEV_NAME=$DRIVER.0
BLOCK_DEV="/dev/disk/by-path/platform-$DEV_NAME"

exec $(dirname $0)/../common/unbind-bind-write.sh \
	"$DRIVER" "$DEV_NAME" "$BLOCK_DEV"
