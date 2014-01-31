#!/bin/sh

set -e
#set -x

echo "mmcif dmesg feature test"

exec $(dirname $0)/../common/dmesg.sh "sh_mmcif sh_mmcif: driver"
