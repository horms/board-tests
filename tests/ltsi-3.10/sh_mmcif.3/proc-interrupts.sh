#!/bin/sh

set -e
#set -x

echo "mmcif /proc/interrupts presence test"

IRQ=89
if $(dirname $0)/../common/proc-interrupts.sh \
	"$IRQ:*"; then
	echo "Test passed"
else
	echo "Test has not passed"
fi
