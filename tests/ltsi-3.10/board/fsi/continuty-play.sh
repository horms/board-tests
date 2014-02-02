#!/bin/bash
# fsi device driver autotest shell-script

set -e
#set -x

echo "`date`   fsi driver autotest"

for i in 1 2 3 4 5
do
	aplay -D hw:0,0 -f S16_LE -t wav  /tmp/record$i.wav
done

