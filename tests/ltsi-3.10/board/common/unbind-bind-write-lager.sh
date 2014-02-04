#!/bin/sh
# unbind-bind-write-lager.sh
#
# Simple test of unbinding and re-binding a device followed
# by writing to an associated block device
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

if [ $# -ne 3 ]; then
	echo "usage: $(basename $0) DRIVER DEVICE_NAME BLOCK_DEVICE" >& 2
	exit 1
fi

$(dirname $0)/../common/unbind-bind-lager.sh "$@"

echo "Perform write test"

exec $(dirname $0)/../common/write-dd.sh "$3-part1" 1M 10

