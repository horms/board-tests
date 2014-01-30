#!/bin/sh

set -e
#set -x

echo "sdhi.1 /proc/interrupts presence test"

IRQ=154
DIV_NAME="sh_mobile_sdhi.1"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
        echo "Test passed"
else
        echo "Test has not passed"
fi
