#!/bin/sh

set -e
#set -x

echo "sh_cmt.0 /proc/interrupts presence test"

IRQ=174
DIV_NAME="sh_cmt.0"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
	echo "Test passed"
else
	echo "Test has not passed"
fi
