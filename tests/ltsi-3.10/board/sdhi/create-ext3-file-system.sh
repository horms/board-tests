#! /bin/bash
#Creating partition and making file system for card 
#Step01:
#Checking what is the file sytem type of the card ?
#	If step01 is ext3,exit proccess
#	If step01 is not ext3,change to step02
#Step02:
#Creating a partiton and making ext3 file system for card

#Step01
echo "Checking what is the file system type of card?(ext3)"
dmesg | grep "mmcblk1" > /dev/null 2>&1
if [ $? -eq 0  ] ;then
	blk=1
else
	blk=2
fi

echo "Mounting card to work"
if [ $blk -eq 1 ]; then
	mount /dev/mmcblk1p1 /mnt/ > /dev/null 2>&1
	mount | grep "/dev/mmcblk1p1 on /mnt type ext3" > /dev/null 2>&1
else
	mount /dev/mmcblk2p1 /mnt/ > /dev/null 2>&1
	mount | grep "/dev/mmcblk2p1 on /mnt type ext3" > /dev/null 2>&1
fi

if [ $? -eq 0 ] ;then
	umount /mnt/ > /dev/null 2>&1
	echo "Not need to make file system so it is already a ext3 file sytem"
	dmesg -c > /dev/null 2>&1
	exit 1
else
	umount /mnt/ > /dev/null 2>&1
	echo "Need to creating a partiton and making ext3 file system for card"
	dmesg -c > /dev/null 2>&1
fi

#Step02
echo "Creating a partiton for card"
(echo o; echo n; echo p; echo 1; echo 2048; echo "+600M"; echo t; echo 83; \
	echo w) | fdisk /dev/mmcblk${blk} > /dev/null 2>&1

echo "Make ext3 file system for card"
mkfs.ext3 /dev/mmcblk${blk}p1 > /dev/null 2>&1

echo "Creating partition and making file system done"
