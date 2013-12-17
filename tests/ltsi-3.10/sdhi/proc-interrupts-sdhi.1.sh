#!/bin/sh

set -e
#set -x

echo "sdhi.1 /proc/interrupts presence test"

IRQ=154
if $(dirname $0)/../common/proc-interrupts.sh \
	"$IRQ:*"; then
	echo "Test passed"
else
	echo "Test has not passed"
fi
