#!/bin/sh

set -e
#set -x

echo "sdhi.0 /proc/interrupts presence test"

IRQ=150
DIV_NAME="sh_mobile_sdhi.0"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
        echo "Test passed"
else
        echo "Test has not passed"
fi
