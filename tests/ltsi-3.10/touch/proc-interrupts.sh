#!/bin/sh

set -e
#set -x

echo "Touch /proc/interrupts presence test"

IRQ=2010
if $(dirname $0)/../common/proc-interrupts.sh \
	"$IRQ:*"; then
	echo "Test passed"
else
	echo "Test has not passed"
fi
