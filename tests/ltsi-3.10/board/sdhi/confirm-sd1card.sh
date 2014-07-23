#!/bin/sh
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

SD1="mmc1"
CARD="mmcblk"
FILE_LOG="/tmp/sdhi.txt"
LOG_INSERT_SD1="$SD1: new "
LOG_REMOVED_SD1="$SD1: card"

#Confirm SD1 card:
if ! dmesg | grep "$LOG_INSERT_SD1" > /dev/null; then
	echo "Could not found SD1 card"
	exit 1
fi
echo "Confirm SD1 Card..."
LOG="`dmesg | grep "$LOG_INSERT_SD1"`"

# Looking for the address of card
NUM=0
for addr in $LOG
do
	ADDR=$addr
	NUM=$(($NUM + 1))
done
#Times of SD1 inserted into slot 1 (CON7)
INSERT=$(($NUM / 9))

#Looking for the name of SD1 device
NUM=0
LOG="`dmesg | grep "$SD1:$ADDR"`"
for COUNT in $LOG
do
	NUM=$(($NUM + 1))
done
NUM=$(($NUM - 4))

COUNT=0
for NAME in $LOG
do
	COUNT=$(($COUNT + 1))
	if [ $COUNT -eq $NUM ];then
		echo $NAME > $FILE_LOG
		break
	fi
done

sleep 1 
for id in 0 1 2 3
do
	if cat $FILE_LOG | grep "$CARD$id" -w > /dev/null; then
		NAME=$CARD$id
		break
	fi
done 
#Finished

#Looking for the times of SD1 card ejected
NUM=0
if dmesg | grep "$LOG_REMOVED_SD1" > /dev/null;then
	LOG="`dmesg | grep "$LOG_REMOVED_SD1"`"
	for count in $LOG
	do
		NUM=$(($NUM + 1))	
	done
fi

if [ $NUM -eq 0 ]; then
	EJECT=0
else
	EJECT=$( printf "%.0f" $(($NUM / 4)) )
fi
#Finished

# Confirm SD1 card on slot 1(CON7)
if [ $INSERT -gt $EJECT ]; then
	sleep 2
	if /bin/ls /dev | grep $NAME -w > /dev/null;then
		echo "FOUND SD1 ($NAME) ON SLOT 1(CON7)"
	else
		echo "COULD NOT FOUND SD1 ON SLOT 1(CON7)"
	fi
elif [ $INSERT -eq $EJECT ]; then
	echo "SD1 HAS BEEN REMOVED FROM SLOT 1(CON7)"
else
	echo "TEST FAILED"
	exit 1
fi

rm -rf $FILE_LOG
