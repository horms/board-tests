#!/bin/sh
# dmesg.sh
#
# Simple dmesg based feature test
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

$(dirname $0)/dmesg-quiet.sh "$@"
STATUS="$?"

if [ "$STATUS" -eq "0" ]; then
	echo "Test passed"
fi

exit "$STATUS"
