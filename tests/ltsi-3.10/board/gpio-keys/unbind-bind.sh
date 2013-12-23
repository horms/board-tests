#!/bin/sh

set -e
#set -x

echo "gpio-keys unbind/bind test"

if [ $# -ne 0 ]; then
	echo "usage: $(basename $0)" >& 2
	exit 1
fi

DRIVER="gpio-keys"
DEV_NAME="$DRIVER"

exec $(dirname $0)/../common/unbind-bind.sh \
	"$DRIVER" "$DEV_NAME"
