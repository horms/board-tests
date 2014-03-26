#!/bin/sh
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"

FILE="/tmp/ceu.txt"

# Show the image on LCDC
echo "Show the image on LCDC..." 
$(dirname $0)/../common/ceu-show-image.py $BOARD_USERNAME $BOARD_HOSTNAME

# Kill the GST process id:
NUM=0
sleep 2
if ssh $BOARD_USERNAME@$BOARD_HOSTNAME /bin/ps axf | grep "gst-launch-0.10" > $FILE;then
sleep 1
PROCESS=`cat $FILE | grep "gst-launch-0.10 v4l2src"`
for id in $PROCESS
do
	NUM=$(($NUM + 1))
	if [ $NUM -eq 1 ];then
		if ! ssh $BOARD_USERNAME@$BOARD_HOSTNAME /bin/kill -9 $id;then
			echo "Could not kill the process $id"
		fi
	fi
done
fi

if [ -f $FILE ]; then
	rm $FILE
fi

