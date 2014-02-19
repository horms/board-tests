#!/bin/sh

set -e
#set -x

echo "ethernet dmesg feature test"
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

exec $(dirname $0)/../common/dmesg.sh "net $IF: attached PHY 0 *"
