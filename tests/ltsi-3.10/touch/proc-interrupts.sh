#!/bin/sh

set -e
#set -x

echo "Touch /proc/interrupts presence test"

IRQ=2010
DIV_NAME="st1232-ts"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
        echo "Test passed"
else
        echo "Test has not passed"
fi
