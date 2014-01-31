#!/bin/bash
# sdhi device driver autotest shell-script

set -e
#set -x

echo "`date`   SDHI driver autotest start"

mkdir -p /mnt/sd0/
mkdir -p /mnt/sd1/
mkdir -p /tmp/temp

src_dir=""
dst_dir=""

PS3='Select a direct to write: '
options=("SD0->RAM" "SD1->RAM" "RAM->SD0" "RAM->SD1" "SD0->SD1" "SD1->SD0" "Quit")
select opt in "${options[@]}"
do
        case $opt in
                "SD0->RAM")
                        echo "writing direct: SD0->RAM"
                        src_dir="/mnt/sd0"
                        dst_dir="/tmp/temp"
                        break
                        ;;
                "SD1->RAM")
                        echo "writing direct: SD1->RAM"
                        src_dir="/mnt/sd1"
                        dst_dir="/tmp/temp"
                        break
                        ;;
                "RAM->SD0")
                        echo "writing direct: RAM->SD0"
                        src_dir="/tmp/temp"
                        dst_dir="/mnt/sd0"
                        break
                        ;;
                "RAM->SD1")
                        echo "writing direct: RAM->SD1"
                        src_dir="/tmp/temp"
                        dst_dir="/mnt/sd1"
                        break
                        ;;
                "SD0->SD1")
                        echo "writing direct: SD0->SD1"
                        src_dir="/mnt/sd0"
                        dst_dir="/mnt/sd1"
                        break
                        ;;
                "SD1->SD0")
                        echo "writing direct: SD1->SD0"
                        src_dir="/mnt/sd1"
                        dst_dir="/mnt/sd0"
                        break
                        ;;
                "Quit")
                        exit
                        ;;
                *) echo invalid option;;
        esac
done

# Mount src_dir and dst_dir
$(dirname $0)/../common/mount-device.sh $src_dir
$(dirname $0)/../common/mount-device.sh $dst_dir

# choose file size for write
read -p "Choose size of file for write --> " answer

# write test
echo "copying ${answer}M file from $src_dir to $dst_dir "
$(dirname $0)/../common/write-common.sh \
        $src_dir $dst_dir 1M ${answer}

# Umount src_dir and dst_dir
$(dirname $0)/../common/umount-device.sh $src_dir
$(dirname $0)/../common/umount-device.sh $dst_dir

rm -rf $src_dir/
rm -rf $dst_dir/
