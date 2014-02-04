#!/bin/sh

set -e
#set -x

echo "sdhi.1 dmesg feature test"

exec $(dirname $0)/../common/dmesg.sh "sh_mobile_sdhi sh_mobile_sdhi.1: mmc0"
