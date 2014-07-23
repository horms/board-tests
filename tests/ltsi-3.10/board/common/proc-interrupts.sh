#!/bin/sh
# dmesg.sh
#
# Simple /proc/interrupts presence test
# 
# Copyright (C) 2013 Horms Soltutions Ltd.
#
# Contact: Simon Horman <horms@verge.net.au>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.

set -e
#set -x

if [ $# -ne 1 ]; then
	echo "usage: $(basename $0) PATTERN" >& 2
	exit 1
fi

PATTERN="$1"
ERROR="error"
ERROR1="Error"
FILE1="/tmp/interrupts"

#echo "/proc/interrupts feature test for '$PATTERN'"
if cat /proc/interrupts | grep "$PATTERN" > $FILE1; then
#begin if
	if cat $FILE1 | grep $ERROR > /dev/null; then
		echo "driver error" >&2
		rm -r $FILE1
		exit 1
	elif cat $FILE1 | grep $ERROR1 > /dev/null; then
		echo "driver error" >&2
		rm -r $FILE1
		exit 1
	else
		cat $FILE1
	fi
#end if
else
	echo "error: not matched" >&2
	rm -r $FILE1
	exit 1
fi

if ! rm -r $FILE1; then
        echo "Could not remove $FILE1"
        exit 1
fi
