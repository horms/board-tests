#!/bin/sh
# write-dev.sh
#
# Simple dd-based write test
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

if [ $# -ne 4 ]; then
	echo "usage: $(basename $0) PATH BLOCK_SIZE BLOCK_COUNT" >& 2
	exit 1
fi

SRC_DEV="$1"
DST_DEV="$2"
BLOCK_SIZE="$3"
BLOCK_COUNT="$4"

echo "test data (bs=$BLOCK_SIZE count=$BLOCK_COUNT)"

echo "Test that device exists"
if [ ! -e "$SRC_DEV" ]; then
	echo \'$SRC_DEV\': No such file or directory >&2
	exit 1
fi

if [ ! -e "$DST_DEV" ]; then
        echo \'$SRC_DE\': No such file or directory >&2
        exit 1

fi

IN=""
OUT=""
cleanup ()
{
    [ -n "$IN" -a -f "$IN" ] && rm "$IN"
    [ -n "$OUT" -a -f "$OUT" ] && rm "$OUT"
}
trap cleanup exit
IN=$(mktemp -p $SRC_DEV/)
OUT=$(mktemp -p $DST_DEV/)

echo "Write random data to test file"
dd if=/dev/urandom of="$IN" bs="$BLOCK_SIZE" count="$BLOCK_COUNT" > /dev/null 2>&1

echo "Write test data to device"
dd if="$IN" of="$OUT" bs="$BLOCK_SIZE" count="$BLOCK_COUNT" > /dev/null 2>&1


IN_SUM=$(sha256sum "$IN" | cut -f 1 -d ' ')
OUT_SUM=$(sha256sum "$OUT" | cut -f 1 -d ' ')

IN_SIZE=$(wc -c "$IN" | cut -f 1 -d ' ')
OUT_SIZE=$(wc -c "$OUT" | cut -f 1 -d ' ')

echo "Compare data writen to data read"
if [ "$IN_SUM" != "$OUT_SUM" ]; then
	echo "Data read does not match data written" >&2
	echo "Size (bytes):" >&2
	echo "    in:  $IN_SIZE" >&2
	echo "    out: $OUT_SIZE" >&2
	echo "SHA 256 Checksums:" >&2
	echo "    in:  $IN_SUM" >&2
	echo "    out: $OUT_SUM" >&2
	exit 1
fi

echo "Test passed"
