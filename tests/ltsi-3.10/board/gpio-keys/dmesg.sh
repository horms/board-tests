#!/bin/sh

set -e
#set -x

echo "gpio-keys dmesg feature test"

exec $(dirname $0)/../common/dmesg.sh "input: gpio-keys"
