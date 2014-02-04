#!/bin/bash

set -e
#set -x

echo "ARM timer interrupt test"

DEV_NAME="arch_timer"

# CMT interrupt test
BEFORE=$($(dirname $0)/../common/interrupt-count.sh "$DEV_NAME")
sleep 5
AFTER=$($(dirname $0)/../common/interrupt-count.sh "$DEV_NAME")

# Show result
echo "Before interrupt:$BEFORE"
echo "After interrupt :$AFTER"

if [ "$BEFORE" -ge "$AFTER" ]; then
	echo "Interrupt cound is not increasing"
	exit 1
else
	echo "Test passed"
fi
