#!/bin/bash
# lcdc device driver autotest shell-script

set -e
#set -x

echo "`date`   lcdc driver autotest"

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

# Show bitmap picture
cp /home/*.bmp $src_dir/
bmap /dev/fb0 $src_dir/*.bmp

# Check result
if [ $? -eq 0 ];then
	echo "Showing picture done"
else
	echo "Showing picture is error"
	exit 1
fi

# Umount src_dir
$(dirname $0)/../common/umount-device.sh $src_dir

rm -rf $src_dir/
