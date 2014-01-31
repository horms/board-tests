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

#echo "/proc/interrupts feature test for '$PATTERN'"

if ! grep "$PATTERN" /proc/interrupts; then
	echo "error: not matched" >&2 
	exit 1
fi

#echo "Test passed"
