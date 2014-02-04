#!/bin/sh

set -e
#set -x

echo "MMCIF 350M write test"

exec $(dirname $0)/../common/write-dd.sh \
	/dev/disk/by-path/platform-sh_mmcif.1-part1 1M 350
