#!/bin/sh

set -e
#set -x

echo "sh-sci /proc/interrupts presence test"

if $(dirname $0)/../common/proc-interrupts.sh \
	"^ *133: *.* *sh-sci.1:mux$"; then
        echo "Test passed"
else
        echo "Test has not passed"
fi
