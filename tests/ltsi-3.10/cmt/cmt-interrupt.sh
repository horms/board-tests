#!/bin/bash

set -e
#set -x

echo "CMT interrupt test"

DEV_NAME="sh_cmt.10"

# CMT interrupt test
$(dirname $0)/../common/interrupt-count.sh "$DEV_NAME" > bef
sleep 5
$(dirname $0)/../common/interrupt-count.sh "$DEV_NAME" > aft

# Filter interrupt number
read BEFORE < bef
BEFORE=${BEFORE%% [A-Z]*}
BEFORE=${BEFORE#* }

read AFTER < aft
AFTER=${AFTER%% [A-Z]*}
AFTER=${AFTER#* }

# Show result
echo "Before interrupt:$BEFORE"
echo "After interrupt :$AFTER"

if [ "$BEFORE" -ge "$AFTER" ]; then
	echo "Interrupt cound is not increasing"
	exit 1
else
	echo "Test passed"
fi
