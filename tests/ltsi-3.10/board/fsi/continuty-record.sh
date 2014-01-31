#!/bin/bash
# fsi device driver autotest shell-script

set -e
#set -x

echo "`date`   fsi driver autotest"

for i in 1 2 3 4 5
do
	arecord -D hw:0,0 -c 2 -f S16_LE -t wav -r 44100 /tmp/record$i.wav -d 20
done

