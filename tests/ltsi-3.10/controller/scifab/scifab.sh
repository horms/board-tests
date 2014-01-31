#!/bin/sh
# scifab device driver autotest shell-script

set -e
#set -x

LOCAL_TTY="/dev/ttyS0"
BOARD_HOSTNAME="armadillo800"
BOARD_USERNAME="root"
BOARD_TTY="/dev/ttySC1"

# Run tty-ping.py to connect Host PC with the Board
$(dirname $0)/../common/tty-ping.py $LOCAL_TTY $BOARD_HOSTNAME $BOARD_USERNAME $BOARD_TTY

