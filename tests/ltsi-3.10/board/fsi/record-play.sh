#!/bin/bash
# fsi device driver autotest shell-script

set -e
#set -x

echo "`date`   fsi driver autotest"

# Record audio file
arecord -D hw:0,0 -c 2 -f S16_LE -t wav -r 8000 /tmp/record1.wav -d 10
arecord -D hw:0,0 -c 2 -f S16_LE -t wav -r 16000 /tmp/record2.wav -d 10
arecord -D hw:0,0 -c 2 -f S16_LE -t wav -r 32000 /tmp/record3.wav -d 10
arecord -D hw:0,0 -c 2 -f S16_LE -t wav -r 44100 /tmp/record4.wav -d 10
arecord -D hw:0,0 -c 2 -f S16_LE -t wav -r 48000 /tmp/record5.wav -d 10

arecord -D hw:0,0 -c 2 -f S24_LE -t wav -r 8000 /tmp/record6.wav -d 10
arecord -D hw:0,0 -c 2 -f S24_LE -t wav -r 16000 /tmp/record7.wav -d 10
arecord -D hw:0,0 -c 2 -f S24_LE -t wav -r 32000 /tmp/record8.wav -d 10
arecord -D hw:0,0 -c 2 -f S24_LE -t wav -r 44100 /tmp/record9.wav -d 10
arecord -D hw:0,0 -c 2 -f S24_LE -t wav -r 48000 /tmp/record10.wav -d 10

if [ $? -eq 0 ]; then
	echo "Record have passed"
else
	echo "Record have not passed"
fi

# Playback audio file
for i in 1 2 3 4 5 6 7 8 9 10
do
	aplay /tmp/record$i.wav
done
 
if [ $? -eq 0 ]; then
        echo "Play have passed"
else
        echo "Play have not passed"
fi

rm -rf /tmp/*
