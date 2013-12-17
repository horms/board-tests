#!/bin/bash

set -e
#set -x

echo "CMT interrupt test"

DEV_NAME="sh_cmt.10"
FIELDS=7

# CMT interrupt test
$(dirname $0)/../common/interrupt-count.sh "$DEV_NAME" "$FIELDS" > bef
read BEFORE < bef
cat bef
sleep 5
$(dirname $0)/../common/interrupt-count.sh "$DEV_NAME" "$FIELDS" > aft
read AFTER < aft
cat aft

# Shou result
echo "$BEFORE"
echo "$AFTER"

if [ "$BEFORE" -ge "$AFTER" ]; then
	echo "Interrupt cound is not increasing"
	exit 1
else
	echo "Test passed"
fi
