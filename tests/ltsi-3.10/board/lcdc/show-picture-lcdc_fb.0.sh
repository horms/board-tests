#!/bin/bash
# lcdc device driver autotest shell-script

set -e
#set -x

echo "`date`   lcdc driver autotest"

if [ $# -ne 1 ]; then
	echo "usage: $(basename $0) [STORAGE_DEVICE]" >& 2
	echo "STORAGE_DEVICE: SD0, SD1, RAM"
	echo "For example: $(basename $0) RAM"
	exit 1
fi

SOURCE="$1"
mkdir -p /mnt/sd0/
mkdir -p /mnt/sd1/
mkdir -p /tmp/temp/

echo "source from: $SOURCE"

for opt in $SOURCE
do
        case $opt in
		"SD0")
			SRC_DIR="/mnt/sd0"
			break
			;;
                "SD1")
                        SRC_DIR="/mnt/sd1"
                        break
                        ;;
                "RAM")
                        SRC_DIR="/tmp/temp"
                        break
                        ;;

                *) echo invalid option;;
        esac
done

$(dirname $0)/../common/mount-device.sh $SRC_DIR

# Show bitmap picture
if ! cp /home/*.bmp $SRC_DIR/ > /dev/null;then
	echo "Coping a bmp file has failed"
	exit 1
fi

echo "Show the image..."
if ! bmap /dev/fb0 $SRC_DIR/*.bmp; then 
	echo "Showing the image has failed"
	exit 1
fi

# Check result
if [ $? -eq 0 ];then
	echo "Showing picture done"
else
	echo "Showing picture is error"
	exit 1
fi

# Umount src_dir
$(dirname $0)/../common/umount-device.sh $SRC_DIR

rm -rf /tmp/*
rm -rf /mnt/*

