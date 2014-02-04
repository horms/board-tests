#!/bin/sh

set -e
#set -x

echo "gpio-keys /proc/interrupts presence test"

OK=0
NG=0

IRQ=416
for SW2 in pin4 pin3 pin2 pin1; do
	if $(dirname $0)/../common/proc-interrupts.sh \
		"$IRQ: \+[0-9]\+ \+gpio_rcar.1 \+ \+SW2-$PIN"; then
		OK=$(($OK + 1))
	else
		NG=$(($NG + 1))
		echo "Could not find $SW" >&2
	fi
	IRQ=$(($IRQ + 1))
done

echo "Passed:$OK Failed:$NG"

if [ "$NG" -ne 0 ]; then
	exit 1
fi
