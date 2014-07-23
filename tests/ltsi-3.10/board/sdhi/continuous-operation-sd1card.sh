#!/bin/sh
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

SD1="mmc1"
CARD="mmcblk"
FILE_LOG="/tmp/sdhi.txt"
LOG_INSERT_SD1="$SD1: new"
LOG_REMOVED_SD1="$SD1: card"

#Confirm sd1 card:
echo "Please Insert/Eject the SD1 card into/from slot 1 for 3 times"

if ! dmesg | grep "$LOG_INSERT_SD1" > /dev/null; then
	echo "Could not found SD1 card"
	exit 1
fi

# The times of SD1 card inserted into SLOT 1
LOG="`dmesg | grep "$LOG_INSERT_SD1"`"
NUM=0
for count in $LOG
do
	NUM=$(($NUM + 1))
done
INSERT=$(($NUM / 9))
echo "Found $INSERT time(s) SD1 inserted into SLOT 1(CON7)"

# The times of SD1 card removed from SLOT 1 
NUM=0
if dmesg | grep "$LOG_REMOVED_SD1" > /dev/null;then
	LOG="`dmesg | grep "$LOG_REMOVED_SD1"`"
	for count in $LOG
	do
		NUM=$(($NUM + 1))
	done
fi
if [ $NUM -eq 0 ];then
	EJECT=0
else
	EJECT=$(($NUM / 4))
fi
echo "Found $EJECT time(s) SD1 ejected from SLOT 1(CON7)"

# Confirm the SD1 card inserted/ejected 3 times?
if [ $INSERT -eq 3 ] && [ $EJECT -eq 3 ];then
	echo "TEST PASSED"
elif [ $INSERT -eq 3 ] && [ $EJECT -le 2 ];then
	echo "Too few Remove of SD1. Wrong operation!"
	echo "TEST FAILED"
	exit 1
elif [ $INSERT -ge 4 ];then
	echo "Too much Insertions of SD1. Wrong operation!"
	echo "TEST FAILED"
	exit 1
else
	echo "Too few Insertions of SD1. Wrong operation!"
	echo "TEST FAILED"
	exit 1
fi

