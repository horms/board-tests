#!/bin/sh
# count interrupt of device

set -e
#set -x

echo "Counting interrupt of given device"

if [ $# -ne 2 ]; then
        echo "usage: $(basename $0) PATTERN" >& 2
        exit 1
fi

$(dirname $0)/../common/proc-interrupts.sh "$1" | cut -f $2 -d ' '
