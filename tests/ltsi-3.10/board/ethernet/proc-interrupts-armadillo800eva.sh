#!/bin/sh

set -e
#set -x

echo "eth0 /proc/interrupts presence test"

IRQ=142
DIV_NAME="eth0"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
	echo "Test passed"
else
	echo "Test has not passed"
fi
