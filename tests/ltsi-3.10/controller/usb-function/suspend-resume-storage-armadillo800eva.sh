#!/bin/sh
# scifab device driver autotest shell-script
# this program is run in /root. Please login /root with 'su' command

set -e
#set -x

LOCAL_TTY="/dev/ttyUSB0"
BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
BOARD_TTY="/dev/ttySC1"
SCI_ID="1"
SIZE="100"

# Run suspend-resume.py to connect Host PC with the Board
if $(dirname $0)/../common/suspend-resume.py $LOCAL_TTY $BOARD_HOSTNAME $BOARD_USERNAME \
	$BOARD_TTY $SCI_ID; then
	sleep 1
	echo "Operation of writing a data from PC to board..."
	$(dirname $0)/../usb-function/storage-tmpfs-pc-storate.sh $BOARD_USERNAME \
	$BOARD_HOSTNAME $SIZE
else
	exit 1
fi

