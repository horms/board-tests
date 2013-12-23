#!/bin/bash
# fsi device driver autotest shell-script

set -e
#set -x

echo "`date`   fsi driver autotest"

mkdir -p /mnt/sd0/
mkdir -p /mnt/sd1/
mkdir -p /tmp/temp/

src_dir=""

PS3='Select a source: '
options=("SD0" "SD1" "RAM" "Quit")
select opt in "${options[@]}"
do
        case $opt in
                "SD0")
                        echo "source: SD0"
                        src_dir="/mnt/sd0"
                        break
                        ;;
                "SD1")
                        echo "source: SD1"
                        src_dir="/mnt/sd1"
                        break
                        ;;
                "RAM")
                        echo "source: RAM"
                        src_dir="/tmp/temp"
                        break
                        ;;
                "Quit")
                        exit
                        ;;
                *) echo invalid option;;
        esac
done

# Mount src_dir
$(dirname $0)/../common/mount-device.sh $src_dir

# Choose format and rate
read -p "Choose format (S16_LE,S24_LE) --> " format
read -p "Choose rate (8000,16000,32000,44100,48000) --> " rate
read -p "Choose record tiem (s) --> " rectime

# record and play audio file
arecord -D hw:0,0 -c 2 -f $format -t wav -r $rate $src_dir/audio-${format}-${rate}.wav -d $rectime
if [ $? -eq 0 ]; then
	echo "Record have passed"
else
	echo "Record have not passed"
fi
 
aplay -D hw:0,0 $src_dir/audio-${format}-${rate}.wav
if [ $? -eq 0 ]; then
        echo "Play have passed"
else
        echo "Play have not passed"
fi

# Umount src_dir
$(dirname $0)/../common/umount-device.sh $src_dir

rm -rf $src_dir/
