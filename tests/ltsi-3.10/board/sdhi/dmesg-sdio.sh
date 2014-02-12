#!/bin/sh

set -e
#set -x

echo "SDIO dmesg feature test"
dmesg1="new SDIO card at address 0001"
dmesg2="Broadcom 4318 WLAN found"
dmesg3="Found chip with id"
OK=0
NG=0

echo "SDIO card dmesg feature test"
if $(dirname $0)/../common/dmesg-quiet.sh "$dmesg1"; then
	dmesg | grep "$dmesg1"
	echo "SDIO card dmesg test passed"
	OK=$(($OK + 1))
else
	echo "SDIO card dmesg feature failed!"
	NG=$(($NG + 1))
fi

echo "Broadcom WLAN dmesg feature test"
if $(dirname $0)/../common/dmesg-quiet.sh "$dmesg2"; then
	dmesg | grep "$dmesg2"
	echo "Broadcom WLAN dmesg test passed"
	OK=$(($OK + 1))
else
	echo "Broadcom WLAN dmesg feature failed!"
	NG=$(($NG + 1))
fi

echo "Chip ID dmesg feature test"
if $(dirname $0)/../common/dmesg-quiet.sh "$dmesg3"; then
	dmesg | grep "$dmesg3"
	echo "Chip ID dmesg test passed"
	OK=$(($OK + 1))
else
	echo "Chip ID dmesg feature failed!"
	NG=$(($NG + 1))
fi	

echo "Passed:$OK Failed:$NG"
