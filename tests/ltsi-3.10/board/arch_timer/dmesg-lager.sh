#!/bin/sh

set -e
#set -x

echo "Arch ARM timer dmesg feature test"

exec $(dirname $0)/../common/dmesg.sh "ARM arch timer >56 bits at 10000kHz"
