#!/bin/sh

set -e
#set -x

echo "sh_mobile_ceu /proc/interrupts presence test"

IRQ=192
DIV_NAME="sh_mobile_ceu.0"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
	echo "Test passed"
else
	echo "Test has not passed"
fi
