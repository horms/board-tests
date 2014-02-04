#!/bin/sh

set -e
#set -x

echo "mmcif /proc/interrupts presence test"

IRQ=89
DIV_NAME="sh_mmc"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
        echo "Test passed"
else
        echo "Test has not passed"
fi
