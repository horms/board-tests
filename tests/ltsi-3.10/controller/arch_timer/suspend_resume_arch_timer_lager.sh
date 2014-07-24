#!/bin/sh
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

LOCAL_TTY="/dev/ttyUSB0"
BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
BOARD_TTY="/dev/ttySC1"
SCI_ID="1"

FILE="/tmp/timer.txt"
TIMER='\arch_timer-interrupt-lager.sh'

# Search for timer file
for count in 1 2
do
	if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME "/usr/bin/find . -name $TIMER -print" \
	> $FILE; then
		echo "Not found file $TIMER"
		exit 1
	fi

	if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME < $FILE; then
		echo "can not run script $TIMER"
		exit 1
	elif [ $count -eq 2 ]; then
		echo "SUSPEND ARCH_TIMER TEST PASSED"
	fi

	# Run suspend-resume.py to connect Host PC with the Board
	if [ $count -eq 1 ]; then
		if $(dirname $0)/../common/suspend-resume.py $LOCAL_TTY $BOARD_HOSTNAME \
		$BOARD_USERNAME $BOARD_TTY $SCI_ID; then
			echo "PASSED"
			sleep 1
		else
			echo "FAILED"
			exit 1
		fi
	fi

	if [ -f $FILE ]; then
		rm $FILE
	fi
done
