#!/bin/bash

## 2018-02-27 13:26
echo -e "\n\n\n
  \033[43;37m################\033[0m ArchLinux Installer \033[43;37m################\033[0m
  \033[43;37m##\033[0m                                                 \033[43;37m##\033[0m
  \033[43;37m##\033[0;33m  A semi-automatic script of install-Arch-Linux  \033[43;37m##\033[0m
  \033[43;37m##\033[0m                                                 \033[43;37m##\033[0m
  \033[43;37m##\033[0;33m                Hope this helps!                 \033[43;37m##\033[0m
  \033[43;37m##\033[0m                                                 \033[43;37m##\033[0m
  \033[43;37m#####################\033[0m Get Start \033[43;37m#####################\033[0m\n\n\n"

echo -ne "\033[32mYou can click 'C' double time to get into normal shell mode in front of every input line.

eg.
> [Double click 'C']
\033[33mGet into bash now. Input 'exit' to exit bash\033[0m

# \033[33m(bash now)\033[0m

\033[47;30mPress any key to continue...\033[0m\033[?25l"
read -n1 -s TMP
echo -e "\n\n\n\n\n\n\n\n\n\n\033[?25h"

UserCommand() {
	STMP=""
	read -n1 -t 1 TMP0
	if [ "$TMP0" == c ]; then
		echo -e "\n\n\033[33mGet into bash now. Input 'exit' to exit bash\033[0m"
		bash
		return 0
	else
		STMP=c"$TMP0"
		return 1
	fi
}

## 分区 ##
Partition() {
	echo -e "\n\n\033[42;37m(1/5)=========> Partition\033[0m\n"
	echo -e "\n\033[32m> Adjust partition\033[0m\n"
	echo -e "  \033[47;30mPress [   y   ]\033[0m  to partition\n"
	echo -e "  \033[47;30mPress [Any Key]\033[0m  for no"
	read -n1 TMP
	if [ "$TMP" == c ]; then
		UserCommand
		if [ "$?" == 0 ]; then
			Partition
			return
		fi
	fi
	echo -e "\n"
	while [ "$TMP" == y ]; do
		fdisk -l
		echo -e "\n\n\033[32m> Select disk\n"
		echo -e "  Which disk do you want to partition?\033[0m\n"
		echo -e "Input disk name: \033[47;30m/dev/sdX[X: a,b,c,...]\033[0m"
		read -p "> " DISK
		cfdisk $DISK
		while [ true ]; do
			echo -e "\n\n\033[32m> Continue to partition\033[0m\n"
			echo -e "  \033[47;30mPress [   y   ]\033[0m  to partition again\n"
			echo -e "  \033[47;30mPress [Any Key]\033[0m  for no"
			read -n1 TMP
			if [ "$TMP" == c ]; then
				UserCommand
				if [ "$?" == 0 ]; then
					echo -e "\n"
					continue
				else
					break
				fi
			else
				break
			fi
			echo -e "\n"
		done
	done
	echo -e "\n\033[42;37m> Partition    Done!\033[0m\n\n"
}

## 挂载 ##
MountPartition() {
	echo -e "\n\033[32m> Set mount point\033[0m\n"
	PARTITION=""
	if [ "$1" != "/mnt" ]; then
		while [ true ]; do
			echo -e "  \033[32mCreate \033[42;37m$1\033[0;32m mount point?\033[0m\n"
			echo -e "  \033[47;30mPress [   y   ]\033[0m  to Create\n"
			echo -e "  \033[47;30mPress [ Enter ]\033[0m  for no"
			read -n1 TMP
			if [ "$TMP" == c ]; then
				UserCommand
				if [ "$?" == 0 ]; then
					continue
				fi
			fi
			echo -e "\n"
			if [ "$TMP" == y ]; then
				mkdir $1
				break
			elif [ "$TMP" == "" ]; then
				return
			else
				echo -e "  \033[41;37mERROR! Input again (!!!NO UPPERCASE!!!)\033[0m"
			fi
		done
	else
		TMP=y
	fi
	while [ "$TMP" == y ]; do
		if [ "$PARTITION"  == "" ]; then
			#fdisk -l
			echo -e "Input the mount point of \033[47;30m$1\033[0m"
			read -p "> " PARTITION
			echo ""
		fi
		## SWAP
		if [ "$1" == "swap" ]; then
			echo -e "  \033[32mWill swapon $PARTITION\n"
			echo -e "  \033[47;30mPress [   r   ]\033[0m  to change swap partition\n"
			echo -e "  \033[47;30mPress [   m   ]\033[0m  to mkswap and swapon"
			read -n1 TMP
			if [ "$TMP" == c ]; then
				UserCommand
				if [ "$?" == 0 ]; then
					TMP=y
					continue
				fi
			fi
			echo -e "\n"
			if [ "$TMP" == r ]; then
				PARTITION=""
				TMP=y
				continue
			elif [ "$TMP" == m ]; then
				mkswap $PARTITION
				swapon $PARTITION
				break
			else
				echo -e "  \033[41;37mERROR! Input again (!!!NO UPPERCASE!!!)\033[0m"
				TMP=y
				continue
			fi
		## NOT SWAP
		else
			echo -e "  \033[32m$1 will be mounted on $PARTITION\033[0m\n"
			echo -e "  \033[47;30mPress [   r   ]\033[0m  to change mount point\n"
			if [ "$1" == "/mnt" -o "$1" == "/mnt/home" ]; then
				echo -e "  \033[47;30mPress [   e   ]\033[0m  to format it to ext4\n"
				echo -e "  \033[47;30mPress [   b   ]\033[0m  to format it to btrfs\n"
			elif [ "$1" == "/mnt/boot" ]; then
				echo -e "  \033[47;30mPress [   f   ]\033[0m  to format it to fat32\n"
			fi
			echo -e "  \033[47;30mPress [   m   ]\033[0m  to mount $1 on $PARTITION and done"
			read -n1 TMP
			if [ "$TMP" == c ]; then
				UserCommand
				if [ "$?" == 0 ]; then
					TMP=y
					continue
				fi
			fi
			echo -e "\n"
			if [ "$TMP" == r ]; then
				TMP=y
				PARTITION=""
				continue
			elif [ "$TMP" == e ] && ([ "$1" == "/mnt" ] || [ "$1" == "/mnt/home" ] || ([ "$1" != "/mnt" ] && [ "$1" != "/mnt/boot" ] && [ "$1" != "/mnt/home" ])); then
				mkfs.ext4 $PARTITION
				TMP=y
			elif [ "$TMP" == b ] && ([ "$1" == "/mnt" ] || [ "$1" == "/mnt/home" ] || ([ "$1" != "/mnt" ] && [ "$1" != "/mnt/boot" ] && [ "$1" != "/mnt/home" ])); then
				mkfs.btrfs $PARTITION -f
				TMP=y
			elif [ "$TMP" == "f" ] && [ "$1" == "/mnt/boot" ] || ([ "$1" != "/mnt" ] && [ "$1" != "/mnt/boot" ] && [ "$1" != "/mnt/home" ]); then
				mkfs.fat -F32 $PARTITION
				TMP=y
			elif [ "$TMP" == m ]; then
				mount $PARTITION $1
			else
				echo -e "  \033[41;37mERROR! Input again (!!!NO UPPERCASE!!!)\033[0m"
				TMP=y
			fi
		fi
	done
}

## 挂载分区 ##
Mount() {
	echo -e "\n\n\n\033[42;37m(2/5)=========> Mount\033[0m\n"
	MountPartition "/mnt"
	MountPartition "/mnt/boot"
	MountPartition "/mnt/home"
	MountPartition "swap"
	while [ true ]; do
		echo -e "  \033[32mWant to mount more partitions? Input there or press Enter to skip\033[0m\n"
		echo -e "\033[33mOne by One!\033[0m (eg. /mnt/media)"
		read -p "> " TMP
		if [ "$TMP" == "" ]; then
			break
		else
			MountPartition "$TMP"
		fi
	done
	echo -e "\n\033[42;37m> Mount    Done!\033[0m\n\n"
}

## 软件源 ##
EditMirrorList() {
	echo -e "\n\n\n\033[42;37m(3/5)=========> Mirror\033[0m\n"
	if [ ! -e /etc/pacman.d/mirrorlist.bak ]; then
		echo -e "\033[33mBackup /etc/pacman.d/mirrorlist TO /etc/pacman.d/mirrorlist.bak ...\033[0m"
		cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
	fi
	while [ true ]; do
		echo -e "\n\n\033[32m> Edit /etc/pacman.d/mirrorlist\033[0m\n"
		echo -e "  \033[47;30mPress [   c   ]\033[0m  to select China's mirrors only\n"
		echo -e "  \033[47;30mPress [   m   ]\033[0m  to use [ustc] [tsinghua] [163] mirrors\n"
		echo -e "  \033[47;30mPress [   n   ]\033[0m  to edit mirrorlist by yourself with nano\n"
		echo -e "  \033[47;30mPress [   u   ]\033[0m  to unselect all mirrors\n"
		echo -e "  \033[47;30mPress [   r   ]\033[0m  to restore the mirrors\n"
		echo -e "  \033[47;30mPress [   s   ]\033[0m  to see which mirror is in use\n"
		echo -e "  \033[47;30mPress [ Enter ]\033[0m  to finish editing"
		read -n1 TMP
		if [ "$TMP" == c ]; then
			UserCommand
			if [ "$?" == 0 ]; then
				continue
			fi
		fi
		echo -e "\n"
		if [ "$TMP" == c ]; then
			sed -i '/Score/{/China/!{n;s/^/#/}}' /etc/pacman.d/mirrorlist
		elif [ "$TMP" == m ]; then
			echo -e "\n## China\nServer = http://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch\nServer = http://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch\nServer = http://mirrors.163.com/archlinux/\$repo/os/x86_64\n" >> /etc/pacman.d/mirrorlist
		elif [ "$TMP" == n ]; then
			nano /etc/pacman.d/mirrorlist
		elif [ "$TMP" == u ]; then
			sed -i "s/^\b/#/g" /etc/pacman.d/mirrorlist
		elif [ "$TMP" == r ]; then
			cp /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist
		elif [ "$TMP" == s ]; then
			cat /etc/pacman.d/mirrorlist | grep -v "#"
		elif [ "$TMP" == "" ]; then
			break
		fi
		echo -e "\n"
	done
	echo -e "\n\033[42;37m> Mirror    Done!\033[0m\n\n"
}

## 安装基本系统 ##
InstallBaseSystem() {
	echo -e "\n\n\n\033[42;37m(4/5)=========> Install the Base Packages\033[0m\n"
	INSTALL=1
	while [ true ]; do
		if [ "$INSTALL" == 1 ]; then
			INSTALL=0
			pacstrap /mnt base base-devel --force
		fi
		echo -e "  \033[32mSuccessfully installed ?\033[0m\n"
		echo -e "  \033[47;30mPress [   n   ]\033[0m  to reinstall\n"
		echo -e "  \033[47;30mPress [ Enter ]\033[0m  to next step"
		read -n1 TMP
		if [ "$TMP" == c ]; then
			UserCommand
			if [ "$?" == 0 ]; then
				continue
			fi
		fi
		echo -e "\n"
		if [ "$TMP" == n ]; then
			INSTALL=1
			continue
		elif [ "$TMP" == "" ]; then
			break
		else
			echo -e "  \033[41;37mERROR! Input again (!!!NO UPPERCASE!!!)\033[0m"
			continue
		fi
	done
	echo -e "\n\033[42;37m> Install Done!\033[0m\n\n"
}

## 配置系统 ##
ConfigureSystem() {
	echo -e "\n\n\n\033[42;37m(5/5)=========> Configure the System\033[0m\n"
	echo -e "\n\033[32m> Fstab\033[0m\n"
	if [ -e /mnt/etc/fstab ]; then
		echo -e "  \033[33m[WARN] /mnt/etc/fstab exists, make sure there are no errors in fstab file\033[0m"
		echo -e "    Double click "C" key, get into bash and Use \"cat /mnt/etc/fstab\" to see fstab file and check it"
		echo -e "    If you don't know how to fix this, please \033[47;30mPress [ f ]\033[0m to remove it and re-genfstab auto\n"
	else
		genfstab -U /mnt >> /mnt/etc/fstab
	fi
	while [ true ]; do
		echo -e "  \033[32mMake sure the fstab file is OK\033[0m\n"
		echo -e "  \033[47;30mPress [   n   ]\033[0m  to edit fstab file with nano\n"
		echo -e "  \033[47;30mPress [ Enter ]\033[0m  to next step"
		read -n1 TMP
		if [ "$TMP" == c ]; then
			UserCommand
			if [ "$?" == 0 ]; then
				continue
			fi
		fi
		echo -e "\n"
		if [ "$TMP" == e ]; then
			nano /mnt/etc/fstab
		elif [ "$TMP" == f ]; then
			while [ true ]; do
				echo -e "  \033[33m[WARN] Will delete fstab file and re-genfstab! Continue if you know what you're doing\033[0m\n"
				echo -e "  \033[47;30mInput [  yes  ]\033[0m  to delete fstab file and re-genfstab\n"
				echo -e "  \033[47;30mPress [ Enter ]\033[0m  to cancel"
				read -p "> " TMP
				echo ""
				if [ "$TMP" == "yes" ]; then
					rm -f /mnt/etc/fstab
					genfstab -U /mnt >> /mnt/etc/fstab
				elif [ "$TMP" == "" ]; then
					break
				else
					echo -e "  \033[41;37mERROR! Input again (!!!NO UPPERCASE!!!)\033[0m"
					continue
				fi
			done
		elif [ "$TMP" == "" ]; then
			break
		else
			echo -e "  \033[41;37mERROR! Input again (!!!NO UPPERCASE!!!)\033[0m"
		fi
	done
}

Partition
Mount
EditMirrorList
InstallBaseSystem
ConfigureSystem


## Chroot
echo -e "  \033[32mChange root into the new system now\033[0m\n"
wget https://raw.githubusercontent.com/youthug/Arch-Installer/master/config.sh -O /mnt/root/config.sh
chmod +x /mnt/root/config.sh
arch-chroot /mnt /root/config.sh
