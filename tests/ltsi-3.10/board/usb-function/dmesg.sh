#!/bin/sh

set -e
#set -x

echo "renesas_usbhs dmesg feature test"

exec $(dirname $0)/../common/dmesg.sh "renesas_usbhs renesas_usbhs: probed"
