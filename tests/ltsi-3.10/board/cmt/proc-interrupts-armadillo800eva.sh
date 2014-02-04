#!/bin/sh

set -e
#set -x

echo "sh_cmt.10 /proc/interrupts presence test"

IRQ=90
DIV_NAME="sh_cmt.10"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
	echo "Test passed"
else
	echo "Test has not passed"
fi
