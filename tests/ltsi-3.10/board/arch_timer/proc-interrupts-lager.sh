#!/bin/sh

set -e
#set -x

echo "arch_timer /proc/interrupts presence test"

IRQ=27
DIV_NAME="arch_timer"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
	echo "Test passed"
else
	echo "Test has not passed"
fi
