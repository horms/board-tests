#!/bin/sh

set -e
#set -x

echo "lcdc_fb.1 /proc/interrupts presence test"

IRQ=210
DIV_NAME="sh_mobile_lcdc_fb.1"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
        echo "Test passed"
else
        echo "Test has not passed"
fi
