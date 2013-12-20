#!/bin/sh

set -e
#set -x

echo "renesas_usbhs /proc/interrupts presence test"

IRQ=83
DIV_NAME="renesas_usbhs"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
	echo "Test passed"
else
	echo "Test has not passed"
fi
