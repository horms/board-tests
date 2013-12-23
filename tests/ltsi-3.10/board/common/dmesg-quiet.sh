#!/bin/sh
# dmesg-quiet.sh
#
# Simple dmesg based feature test (quiet variant)
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

#echo "dmesg feature test for '$PATTERN'"

if ! dmesg | grep "$PATTERN" > /dev/null; then
	echo "error: not matched" >&2
	exit 1
fi
