#!/bin/sh

set -e
#set -x

echo "sh_mobile_ceu dmesg feature test"

exec $(dirname $0)/../common/dmesg.sh "sh_mobile_ceu sh_mobile_ceu.0"
