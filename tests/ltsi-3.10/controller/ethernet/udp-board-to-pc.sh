#!/bin/sh
# ethenet device driver autotest shell-script
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

if [ $# -ne 2 ]; then
        echo "usage: $(basename $0) HOST_IP_ADDR BOARD_IP_ADDR" >& 2
        echo "For example:$(basename $0) 172.16.1.9 172.16.1.36"
        exit 1
fi

BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
LOG_FILE="/tmp/udp.txt"
LOG_FILE1="/tmp/log"
TYPES="UDP"
TARGET="HOSTPC"
HOSTPC_IP="$1"
BOARD_IP="$2"
BW="M"

# UDP Check: on PC
$(dirname $0)/../common/udp_check.py $BOARD_HOSTNAME $BOARD_USERNAME \
	$LOG_FILE $TARGET

# transfer data from BOARD to HOSTPC:
echo "UDP Check: From BOARD to HOSTPC"
for number in 10 20 30 40 50 60 70 80 90 100
do
	NUM=0
	BANDWITCH=$number$BW
	if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME /usr/bin/iperf -c $HOSTPC_IP -u -b $BANDWITCH > $LOG_FILE1; then
        	echo "Could not transfer data"
	elif cat $LOG_FILE1 | grep "(0%)" > /dev/null; then
		echo "$TYPES: Transfer data: Passed"
	else
		echo "$TYPES: Transfer data: Failed"
	fi

	PARAMETER="`cat $LOG_FILE1 | grep "(0%)"`"
	# Looking for info of Speed
	for info in $PARAMETER
	do
        	NUM=$(($NUM + 1))
        	if [ $NUM -eq 7 ]; then
                	SPEED=$info
        	elif [ $NUM -eq 8 ]; then
                	UNIT="$info"
        	fi
	done
	echo "Speed: $SPEED $UNIT"
	GOOD="`expr $number / 2`"
	INT1=${SPEED/.*}
	INT2=${GOOD/.*}
	if [ $INT1 -ge $INT2 ];then
		echo "TEST $BANDWITCH SPEED: PASSED"
	else
		echo "TEST $BANDWITCH SPEED: FAILED"
	fi

	if [ -f $LOG_FILE1 ]; then
		rm $LOG_FILE1
	fi
	if [ -f $LOG_FILE ]; then
		rm $LOG_FILE
	fi

sleep 1
done

