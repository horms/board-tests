#!/bin/sh

set -e
#set -x

echo "ethernet /proc/interrupts presence test"

IRQ=194
INTERFACE="eth"
# Confirm eth interface:
echo "Confirm $INTERFACE interface on board:"
for id in $(seq 0 20);
do
        IF="$INTERFACE$id"
        if ifconfig -a | grep "$IF" > /dev/null; then
                echo "$IF"
                break
        fi
done

if [ $id -eq 20 ]; then
        echo "Has no $INTERFACE interface!"
        exit 1
fi

if $(dirname $0)/../common/proc-interrupts.sh "$IF" | grep "$IRQ"; then
	echo "Test passed"
else
	echo "Test has not passed"
fi
