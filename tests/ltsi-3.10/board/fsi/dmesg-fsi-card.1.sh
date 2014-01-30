#!/bin/sh

set -e
#set -x

echo "card.1 sh_fsi2 dmesg feature test"

exec $(dirname $0)/../common/dmesg.sh "asoc-simple-card asoc-simple-card.1:  sh_mobile_hdmi-hifi <-> fsib-dai mapping ok"
