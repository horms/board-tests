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

for i in $(seq 0 9); do
	test_one "sh-sci.$i: .* is *"
done

echo "Passed:$OK Failed:$NG"

if [ "$NG" -ne 0 ]; then
	exit 1
fi
