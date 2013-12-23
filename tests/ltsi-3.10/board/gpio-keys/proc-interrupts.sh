#!/bin/sh

set -e
#set -x

echo "gpio-keys /proc/interrupts presence test"

OK=0
NG=0

IRQ=2012
for SW in SW5 SW6 SW3 SW4; do
	if $(dirname $0)/../common/proc-interrupts.sh \
		"$IRQ: \+[0-9]\+ \+renesas_intc_irqpin.1 \+[0-9]\+ \+$SW"; then
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
