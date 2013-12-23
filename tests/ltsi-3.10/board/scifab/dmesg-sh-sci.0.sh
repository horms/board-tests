#!/bin/sh

set -e
#set -x

echo "sh-sci dmesg feature test"


OK=0
NG=0

test_one ()
{
	if $(dirname $0)/../common/dmesg-quiet.sh "$@"; then
		OK=$(($OK + 1))
	else
		NG=$(($NG + 1))
		echo "Could not find $SW" >&2
	fi
}

test_one \
"sh-sci.0: ttySC0 at MMIO 0xe6c40000 (irq = 132, base_baud = 0) is a scifa"

test_one \
"sh-sci.1: ttySC1 at MMIO 0xe6c50000 (irq = 133, base_baud = 0) is a scifa"

test_one \
"sh-sci.2: ttySC2 at MMIO 0xe6c60000 (irq = 134, base_baud = 0) is a scifa"

test_one \
"sh-sci.3: ttySC3 at MMIO 0xe6c70000 (irq = 135, base_baud = 0) is a scifa"

test_one \
"sh-sci.4: ttySC4 at MMIO 0xe6c80000 (irq = 136, base_baud = 0) is a scifa"

test_one \
"sh-sci.5: ttySC5 at MMIO 0xe6cb0000 (irq = 137, base_baud = 0) is a scifa"

test_one \
"sh-sci.6: ttySC6 at MMIO 0xe6cc0000 (irq = 138, base_baud = 0) is a scifa"

test_one \
"sh-sci.7: ttySC7 at MMIO 0xe6cd0000 (irq = 139, base_baud = 0) is a scifa"

test_one \
"sh-sci.8: ttySC8 at MMIO 0xe6c30000 (irq = 140, base_baud = 0) is a scifb"

echo "Passed:$OK Failed:$NG"

if [ "$NG" -ne 0 ]; then
	exit 1
fi
