#!/bin/sh

set -e
#set -x

INTERFACE="eth"
OK=0
NG=0
TEST=0
FILE1="/tmp/ethtoollog"
FILE2="/tmp/duplex-speed"
DUPLEX1="half"
DUPLEX2="full"
SPEED="100"
echo "In order to setup this test you need install ethtool"

echo "\nConfirm $INTERFACE interface:"
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

for duplex in $DUPLEX1 $DUPLEX2
do
	TEST=$(($TEST + 1))
	echo "\nTest duplex $duplex on speed $SPEED Mb/s:"
	if ethtool -s $IF autoneg off speed $SPEED duplex $duplex; then
		echo "Setting up duplex and speed ok"
		ethtool $IF > $FILE1
	else
		echo "Setting up duplex and speed failed!"
	fi

	if cat $FILE1 | grep "Speed: $SPEED" > $FILE2; then
		echo "Setting Speed $SPEED ok"
		OK=$(($OK + 1))
	else
		echo "Setting Speed $SPEED failed"
		NG=$(($NG + 1))
	fi

	if [ $TEST -eq 1 ]; then 
		dx="Half"
	elif [ $TEST -eq 2 ]; then
		dx="Full"
	fi	

	if cat $FILE1 | grep "Duplex: $dx" >> $FILE2; then
        	echo "Setting Duplex $dx ok"
		OK=$(($OK + 1))
	else
        	echo "Setting Duplex $dx failed"
		NG=$(($NG + 1))
	fi

	echo "`cat $FILE2`"

	if [ -f $FILE1 ]; then rm $FILE1
	fi
	if [ -f $FILE2 ]; then rm $FILE2
	fi

done
echo "Passed:$OK Failed:$NG"
