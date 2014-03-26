#!/bin/sh

set -e
#set -x

echo "FSI unbind-bind/record-play test"

DRIVER="fsi-pcm-audio"
DEV_NAME="sh_fsi2"

if ! $(dirname $0)/../common/unbind-bind.sh "$DRIVER" "$DEV_NAME";then
	echo "Test Failed"
	exit 1
else
	echo "Record and play a audio file..."
	sleep 3
	if arecord -D hw:0,0 -c 2 -f S16_LE -t wav -r 44100 /tmp/audio.wav -d 10 > /dev/null; then
		echo "Record a audio file passed"
		if aplay /tmp/audio.wav > /dev/null; then
			echo "Play a audio file passed"
			echo "TEST PASSED"
		else
			echo "Play a audio file failed"
			exit 1
		fi
	else
		echo "Record a audio file failed"
		exit 1
	fi
fi
