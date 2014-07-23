#!/bin/sh
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

SD0="mmc0"
CARD="mmcblk"
FILE_LOG="/tmp/sdhi.txt"
LOG_INSERT_SD0="$SD0: new"
LOG_REMOVED_SD0="$SD0: card"

#Confirm sd0 card:
echo "Please Insert/Eject SD0 into/from slot 0 for 3 times"

if ! dmesg | grep "$LOG_INSERT_SD0" > /dev/null; then
	echo "Could not found SD0 card"
	exit 1
fi

# The times of SD0 card inserted into SLOT 0
LOG="`dmesg | grep "$LOG_INSERT_SD0"`"
NUM=0
for count in $LOG
do
	NUM=$(($NUM + 1))
done
INSERT=$(($NUM / 9))
echo "Found $INSERT time(s) SD0 inserted into SLOT 0(CON8)"

# The times of SD0 card removed from SLOT 0 
NUM=0
if dmesg | grep "$LOG_REMOVED_SD0" > /dev/null;then
	LOG="`dmesg | grep "$LOG_REMOVED_SD0"`"
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
echo "Found $EJECT time(s) SD0 ejected from SLOT 0(CON8)"

# Confirm the SD0 card inserted/ejected 3 times?
if [ $INSERT -eq 3 ] && [ $EJECT -eq 3 ];then
	echo "TEST PASSED"
elif [ $INSERT -eq 3 ] && [ $EJECT -le 2 ];then
	echo "Too few Remove of SD0. Wrong operation!"
	echo "TEST FAILED"
	exit 1
elif [ $INSERT -ge 4 ];then
	echo "Too much Insertions of SD0. Wrong operation!"
	echo "TEST FAILED"
	exit 1
else
	echo "Too few Insertions of SD0. Wrong operation!"
	echo "TEST FAILED"
	exit 1
fi

