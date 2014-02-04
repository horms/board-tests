#!/bin/sh

set -e
#set -x

echo "mmcif /proc/interrupts presence test"

IRQ=202
DIV_NAME="sh_mmcif"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
        echo "Test passed"
else
        echo "Test has not passed"
fi
