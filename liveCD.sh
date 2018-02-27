#!/bin/bash

## 旧版

##分区
echo -e "\033[32mDo yout want to adjust the partition ?\033[0m"
read -p "(Input y to use cfdisk ro Enter to skip : " TMP
if [ "$TMP" == y ]
then
	echo -e "\033[32mWhich disk do you want to partition ?\033[0m"
	read -p "(/dev/sdX: " DISK
	CONTINUE=y
	while [ "$CONTINUE" == y ]
	do
		fdisk -l
		cfdisk $DISK
		echo -e "\033[32mContinue ?\033[0m"
		read -p "(Input y to partition ro Enter to next step : " CONTINUE
	done
fi
fdisk -l
echo -e "\033[32mUse default mount points ?\033[0m"
echo -e "\033[33m(/:/dev/sda6    /mnt/boot:/dev/sda1    /mnt/home:/dev/sdb5    swap:/dev/sdb6\033[0m"
read -p "(y or Enter to select your own partition : " DEFAULT
if [ "$DEFAULT" == y ]
then
	ROOT=/dev/sda6
	BOOT=/dev/sda1
	HOME=/dev/sdb5
	SWAP=/dev/sdb6
	#read -p "Format /, /mnt/home mount points ? (y or Enter: " TMP
	#if [ "$TMP" == y ]
	#then
		#read -p "Input y to use ext4 , default to use btrfs: " TMP
		#if [ "$TMP" == y ]
		#then
		#	mkfs.ext4 $ROOT
		#	mkfs.ext4 $HOME
		#else
			mkfs.btrfs $ROOT -f
			mkfs.btrfs $HOME -f
		#fi
	#fi
	#read -p "Format swap mount point ? (y or Enter: " TMP
	#if [ "$TMP" == y ]
	#then
		mkswap $SWAP
	#fi
	##read -p "Format /mnt/boot mount point ? (y or Enter: " TMP
	##if [ "$TMP" == y ]
	##then
	##	mkfs.fat -F32 $BOOT
	##fi
	mount $ROOT /mnt
	mkdir /mnt/boot
	mount $BOOT /mnt/boot
	mkdir /mnt/home
	mount $HOME /mnt/home
	swapon $SWAP
else
	## /mnt
	fdisk -l
	echo -e "\033[32mInput the / mount point : \033[0m"
	read ROOT
	echo -e "\033[31mFormat it ?\033[0m"
	read -p "(y or Enter: " TMP
	if [ "$TMP" == y ]
	then
		echo -e "\033[33mInput y to use ext4 , Enter to use btrfs : \033[0m"
		read TMP
		if [ "$TMP" == y ]
		then
			mkfs.ext4 $ROOT
		else
			mkfs.btrfs $ROOT -f
		fi
	fi
	mount $ROOT /mnt
	## /boot
	echo -e "\033[32mCreate a /boot mount point ?\033[0m"
	read -p "(y or Enter to skip : " BOOT
	if [ "$BOOT" == y ]
	then
		fdisk -l
		echo -e "\033[33mInput the /boot mount point : \033[0m"
		read BOOT
		echo -e "\033[31mFormat it ?\033[0m"
		read -p "(y or Enter to skip : " TMP
		if [ "$TMP" == y ]
		then
			echo -e "\033[31mAre you sure ? Format the /boot partition, the other Operating Systems maybe broken !\033[0m"
			read -p "(Input y to format it : " TMP
				if [ "$TMP" == y ]
				then
					mkfs.fat -F32 $BOOT
				fi
		fi
		mkdir /mnt/boot
		mount $BOOT /mnt/boot
	fi
	## /home
	echo -e "\033[32mCreate a /home mount point ?\033[0m"
	read -p "(y or Enter to skip : " HOME
	if [ "$HOME" == y ]
	then
		fdisk -l
		echo -e "\033[33mInput the /home mount point : \033[0m"
		read HOME
		echo -e "\033[31mFormat it ?\033[0m"
		read -p "(y or Enter to skip : " TMP
		if [ "$TMP" == y ]
		then
			echo -e "\033[33mInput y to use ext4 , default to use btrfs : \033[0m"
			read TMP
			if [ "$TMP" == y ]
			then
				mkfs.ext4 $HOME
			else
				mkfs.btrfs $HOME -f
			fi
		fi
		mkdir /mnt/home
		mount $HOME /mnt/home
	fi
	## swap
	echo -e "\033[32mCreate a swap mount point ?\033[0m"
	read -p "(y or Enter to skip : " TMP
	if [ "$TMP" == y ]
	then
		fdisk -l
		echo -e "\033[33mInput the swap mount point : \033[0m"
		read SWAP
		echo -e "\033[31mFormat it ?\033[0m"
		read -p "(y or Enter to skip : " TMP
		if [ "$TMP" == y ]
		then
			mkswap $SWAP
		fi
		swapon $SWAP
	fi
fi
## 软件源
## sed -i '/Score/{/China/!{n;s/^/#/}}' /etc/pacman.d/mirrorlist 选择中国的源
echo -e "\033[32mDo you want to edit the /etc/pacman.d/mirrorlist ?\033[0m"
read -p "(y or Enter to skip : " TMP
	if [ "$TMP" == y ]
	then
		sed -i "s/^\b/#/g" /etc/pacman.d/mirrorlist
		nano /etc/pacman.d/mirrorlist
	fi
echo -e "\033[32mEdit the /etc/pacman.conf ?\033[0m"
read -p "(y or Enter: " TMP
if [ "$TMP" == y ]
then
	nano /etc/pacman.conf
fi
## 安装基本系统
TMP=n
while [ "$TMP" == n ]
do
	pacstrap /mnt base base-devel --force
	echo -e "\033[33mSuccessfully installed ?\033[0m"
	read -p "(Press n to re-install, or Enter to continue : " TMP
done
## fstab
rm /mnt/etc/fstab
genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
echo -e "\033[32mEdit the /mnt/etc/fstab ?\033[0m"
read -p "(y or Enter to skip : " TMP
if [ "$TMP" == y ]
then
	nano /mnt/etc/fstab
fi
## 进入已安装的系统
wget https://raw.githubusercontent.com/youthug/ArchLinux-Installer/master/config.sh
mv config.sh /mnt/root/config.sh
chmod +x /mnt/root/config.sh
arch-chroot /mnt /root/config.sh
