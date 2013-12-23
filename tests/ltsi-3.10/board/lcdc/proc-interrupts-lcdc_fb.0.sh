#!/bin/sh

set -e
#set -x

echo "lcdc_fb.0 /proc/interrupts presence test"

IRQ=209
DIV_NAME="sh_mobile_lcdc_fb.0"
if $(dirname $0)/../common/proc-interrupts.sh "$DIV_NAME" | grep "$IRQ"; then
        echo "Test passed"
else
        echo "Test has not passed"
fi
