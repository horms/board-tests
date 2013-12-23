#!/bin/sh

set -e
#set -x

echo "SDHI 1k write test"

exec $(dirname $0)/../common/write-dd.sh \
	/dev/disk/by-path/platform-sh_mobile_sdhi.0 1M 10
