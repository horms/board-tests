#!/bin/sh
# count interrupt of device

set -e
#set -x

if [ $# -ne 1 ]; then
        echo "usage: $(basename $0) PATTERN" >& 2
        exit 1
fi

IRQ=""

$(dirname $0)/../common/proc-interrupts.sh "$1" > irq_temp

# Filter interrupt number
read IRQ < irq_temp
IRQ=${IRQ%% [A-Za-z]*}
IRQ=${IRQ#* }
echo $IRQ
