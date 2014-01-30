#!/bin/bash
# usb-function device driver autotest shell-script

set -e
#set -x

echo "Test usb-function: storage is sd card"

# Make work directory on the host PC
mkdir -p /home/data/

# Make partition of storage on the Board
# Check sd card
if ssh root@armadillo800 /bin/dmesg | grep "mmcblk1" > /dev/null; then
	echo "Board: insertted the sd card"
	#mkfs.ext3 -L storage /dev/mmcblk1p1 > /dev/null
else
	echo "Board: did not insert the sd card"
	exit 1
fi

# Load the usb storage module
if ssh root@armadillo800 /sbin/modprobe g_mass_storage file=/dev/mmcblk1p1 > /dev/null; then
	echo "Board: Loading is OK"
else
	echo "Board: Loading is error"
	exit 1
fi

# Confirm storage have was mountted on the host PC
sleep 5
if find /media -name storage > /dev/null; then
	echo "Host PC: storage mount is OK"
else
	echo "Host PC: storage mount is error"
	exit 1
fi

src_dir=""
dst_dir=""

PS3='Select a direct to write: '
options=("PC->Board" "Board->PC" "Quit")
select opt in "${options[@]}"
do
        case $opt in
                "PC->Board")
                        echo "writing direct: PC->Board"
                        src_dir="/home/data"
                        dst_dir="/media/storage"
                        break
                        ;;
                "Board->PC")
                        echo "writing direct: Board->PC"
                        src_dir="/media/storage"
                        dst_dir="/home/data"
                        break
                        ;;
                "Quit")
                        exit
                        ;;
                *) echo invalid option;;
        esac
done

# choose file size for write
read -p "Choose size of file for write (100,500,1024MB)--> " answer

# write test
echo "copying ${answer}M file from $src_dir to $dst_dir "
$(dirname $0)/../../board/common/write-common.sh \
        $src_dir $dst_dir 1M ${answer}

#rm -rf $src_dir/
#rm -rf $dst_dir/

# Umount storage on the host PC
umount /media/storage

# Unload storage module on the Board
if ssh root@armadillo800 /sbin/rmmod g_mass_storage.ko > /dev/null; then
        echo "Board: Unloading is OK"
else
        echo "Board: Unloading is error"
        exit 1
fi
