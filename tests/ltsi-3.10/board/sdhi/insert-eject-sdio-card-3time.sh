#!/bin/sh

set -e
#set -x

dmesg1="new SDIO card at address 0001"
dmesg4="card 0001 removed"
OK=0
NG=0
FILE1="/tmp/dmesg-sdio"
FILE2="/tmp/dmesg-card-removed"

echo "Please Insert/eject sdio card 3 times!"

echo "\n Insert SDIO card dmesg feature test:"
if $(dirname $0)/../common/dmesg-quiet.sh "$dmesg1"; then
	dmesg | grep "$dmesg1" > $FILE1
	echo "Insert SDIO card dmesg test passed"
	OK=$(($OK + 1))
else
	echo "Insert SDIO card dmesg feature failed!"
	NG=$(($NG + 1))
fi

echo "Card removed dmesg feature test:"

if $(dirname $0)/../common/dmesg-quiet.sh "$dmesg4"; then
	dmesg | grep "$dmesg4" > $FILE2
	echo "Card removed dmesg test passed"
	OK=$(($OK + 1))
else
	echo "Card removed dmesg feature failed!"
	NG=$(($NG + 1))
fi      

if [ $NG -eq 0 ]; then
	length1=`wc -l $FILE1 | cut -c1-1`
	length2=`wc -l $FILE2 | cut -c1-1`
	if [ $length1 -eq $length2 ]; then
	echo "Found $length1 times insert/eject the wifi-card!"
		if [ $length1 -ge 3 ]; then
			echo "Test passed!"
		else
			echo "Test Failed!"
		fi
	else	
		echo "Insert/Eject the wifi-card has failed or your operation is wrong!"
	fi
else
	exit 1
fi

if [ $OK -eq 1 ]; then rm $FILE1
elif [ $OK -eq 2 ]; then 
	rm $FILE1
	rm $FILE2
else
	exit 1
fi
echo "Passed:$OK Failed:$NG"

