#!/bin/sh
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

SD0="mmc0"
CARD="mmcblk"
FILE_LOG="/tmp/sdhi.txt"
LOG_INSERT_SD0="$SD0: new high speed SDHC card"
LOG_REMOVED_SD0="$SD0: card"

#Confirm sd0 card:
if ! dmesg | grep "$LOG_INSERT_SD0" > /dev/null; then
	echo "Could not found SD0 card"
	exit 1
fi
echo "Confirm SD0 Card..."
LOG="`dmesg | grep "$LOG_INSERT_SD0"`"

# Looking for the address of card
NUM=0
for addr in $LOG
do
	ADDR=$addr
	NUM=$(($NUM + 1))
done
#Times of SD0 inserted into slot0 (CON8)
INSERT=$(($NUM / 9))

#Looking for the name of SD0 device
NUM=0
LOG="`dmesg | grep "$SD0:$ADDR"`"
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

#Looking for the times of sd0 card ejected
NUM=0
if dmesg | grep "$LOG_REMOVED_SD0" > /dev/null;then
	LOG="`dmesg | grep "$LOG_REMOVED_SD0"`"
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

# Confirm SD0 card on slot 0(CON8)
if [ $INSERT -gt $EJECT ]; then
	sleep 2
	if /bin/ls /dev | grep $NAME -w > /dev/null;then
		echo "FOUND SD0 ($NAME) ON SLOT 0(CON8)"
	else
		echo "COULD NOT FOUND SD0 ON SLOT 0(CON8)"
	fi
elif [ $INSERT -eq $EJECT ]; then
	echo "SD0 HAS BEEN REMOVED FROM SLOT 0(CON8)"
else
	echo "TEST FAILED"
	exit 1
fi

rm -rf $FILE_LOG
