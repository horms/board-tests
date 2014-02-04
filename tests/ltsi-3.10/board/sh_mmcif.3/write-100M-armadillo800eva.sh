#!/bin/sh

set -e
#set -x

echo "MMCIF 100M write test"

exec $(dirname $0)/../common/write-dd.sh \
	/dev/disk/by-path/platform-sh_mmcif-part3 1M 100
