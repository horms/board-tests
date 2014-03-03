#!/bin/sh
# ethenet device driver autotest shell-script
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

if [ $# -ne 2 ]; then
        echo "usage: $(basename $0) PC_IP_ADDR BOARD_IP_ADDR" >& 2
        echo "For example:$(basename $0) 172.16.1.9 172.16.1.36"
        exit 1
fi

BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
LOG_FILE="/tmp/tcp.txt"
UNIT="Mbits/s"
PC_IP="$1"
BOARD_IP="$2"

for num in 1 2
do
if [ $num -eq 2 ]; then
	TARGET="BOARD"
	# CTP Check: on board
	echo "CTP Check: From PC to BOARD:"
	$(dirname $0)/../common/tcp_check.py $BOARD_HOSTNAME $BOARD_USERNAME \
	$BOARD_IP $TARGET $LOG_FILE
elif [ $num -eq 1 ]; then
	TARGET="PC"
	# CTP Check: on pc:
	echo "CTP Check: From BOARD to PC:"
	$(dirname $0)/../common/tcp_check.py $BOARD_HOSTNAME $BOARD_USERNAME \
	$PC_IP $TARGET $LOG_FILE
fi

sleep 1
# transfer data from HOSTPC to BOARD:
PARAMETER="`cat $LOG_FILE | grep "$UNIT"`"

# Looking for info of Speed
NUM=0
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
INT1=${SPEED/.*}
if [ $INT1 -ge 50 ];then
	echo "TEST $BANDWITCH SPEED: PASSED"
else
	echo "TEST $BANDWITCH SPEED: FAILED"
fi

if [ -f $LOG_FILE ]; then
	rm -rf $LOG_FILE
fi
done
