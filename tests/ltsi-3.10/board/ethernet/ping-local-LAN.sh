#!/bin/sh
# ethernet device driver autotest shell-script

set -e
#set -x

if [ $# -ne 2 ]; then
        echo "usage: $(basename $0) LAN_IP_ADDR BOARD_IP_ADDR" >& 2
	echo "For example: $(basename $0) 172.16.1.9 172.16.1.36"
        exit 1
fi

OK=0
NG=0
LANPC_IP="$1"
BOARD_IP="$2"
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

# Confirm eth device on the Board
if ifconfig $IF $BOARD_IP up > /dev/null; then
	echo "Board: $BOARD_IP is up"
else
	echo "Board: $BOARD_IP is not up"
	exit 1
fi

sleep 1

# Ping the Board -> the host PC
if ping -c 5 $LANPC_IP > /dev/null; then
	echo "Ping from Board -> PC LAN: Passed"
	OK=$(($OK + 1))
else
	echo "Ping from Board -> PC LAN: Failed"
	NG=$(($NG + 1))
fi

echo "Passed:$OK Failed:$NG"
