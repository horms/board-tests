#!/bin/sh

set -e
#set -x

echo "ethernet dmesg feature test"

exec $(dirname $0)/../common/dmesg.sh "net eth0: attached PHY 0 *"
