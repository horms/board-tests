#!/bin/sh

set -e
#set -x

echo "lcdc_fb.0 /proc/interrupts presence test"

IRQ=209
if $(dirname $0)/../common/proc-interrupts.sh \
	"$IRQ:*"; then
	echo "Test passed"
else
	echo "Test has not passed"
fi
