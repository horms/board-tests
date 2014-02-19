#!/bin/sh

set -e
#set -x

INTERFACE="eth"
OK=0
NG=0
echo "\n Confirm $INTERFACE interface:"
for id in $(seq 0 20); 
do
	IF="$INTERFACE$id"
	if ifconfig -a | grep "$IF" > /dev/null; then
		echo "$IF."
		break
	fi
done

if [ $id -eq 20 ]; then
	echo "Has no $INTERFACE interface!"
	exit 1
fi

echo "Interface $IF up:"
if ifconfig $IF up > /dev/null; then
	echo "UP"
	OK=$(($OK + 1))
else
	echo "NOT UP"
	NG=$(($NG + 1))
fi

sleep 1

echo "Interface $IF down:"
if ifconfig $IF down ; then
	echo "DOWN"
	OK=$(($OK + 1))
else
	echo "NOT DOWN"
	NG=$(($NG + 1))
fi
echo "Passed:$OK Failed:$NG"

