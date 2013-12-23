#!/bin/sh

set -e
#set -x

echo "sh_fsi2 /proc/interrupts presence test"

IRQ=41
DIV_NAME="sh_fsi2"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
	echo "Test passed"
else
	echo "Test has not passed"
fi
