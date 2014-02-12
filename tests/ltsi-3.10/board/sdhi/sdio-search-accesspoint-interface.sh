#!/bin/sh

set -e
#set -x

INTERFACE="wlan"
OK=0
NG=0
FILE="/tmp/accesspoint"
echo "Note: In order to run this script for test this case, you should install iw tool!"
echo "\nConfirm wlan interface:"
for id in $(seq 0 20); 
do
	IF="$INTERFACE$id"
	if ifconfig -a | grep "$IF" > /dev/null; then
		echo "$IF."
		break
	fi
done

if [ $id -eq 20 ]; then
	echo "Has no wlan interface!"
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

if iw $IF scan | grep "SSID:" > $FILE; then
        length=`wc -l $FILE | cut -c1-1`
        echo "Found $length access point(s) around here:"
	echo "`cat $FILE`"
	OK=$(($OK + 1)) 
else
	echo "Not found any access points around here!"
	NG=$(($NG + 1))
fi


if [ $OK -eq 2 ]; then rm $FILE
else exit 1
fi

echo "Passed:$OK Failed:$NG"

