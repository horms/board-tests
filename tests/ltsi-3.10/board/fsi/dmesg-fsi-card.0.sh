#!/bin/sh

set -e
#set -x

echo "card.0 sh_fsi2 dmesg feature test"

exec $(dirname $0)/../common/dmesg.sh "asoc-simple-card asoc-simple-card.0:  wm8978-hifi <-> fsia-dai mapping ok"
