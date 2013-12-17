#!/bin/sh

set -e
#set -x

echo "Touch dmesg feature test"

exec $(dirname $0)/../common/dmesg.sh "input: st1232-touchscreen"
