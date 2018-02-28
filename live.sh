#!/bin/bash

## 2018-02-27 13:26

N() {
	echo -e "$1"
}
# Green
G() {
	echo -e "\033[32m$1\033[0m"
}
# Yellow
Y() {
	echo -e "\033[33m$1\033[0m"
}
R() {
	echo -e "\033[31m$1\033[0m"
}
# Black on White
BoW() {
	echo -e "\033[47;30m$1\033[0m"
}
# Black on Green
BoG() {
	echo -e "\033[42;30m$1\033[0m"
}
# White on Yellow
WoY() {
	echo -e "\033[43;37m$1\033[0m"
}

ERROR() {
	echo -e "\033[41;37m[ERROR]\033[0;31m  Command not found. Please try again."
}

UserCommand() {
	STMP=""
	read -n1 -s -t 1 TMP0
	if [ "$TMP0" == c ]; then
		G "> Get into bash now. Input 'exit' to exit bash"
		bash
		return 0
	else
		STMP=c"$TMP0"
		return 1
	fi
}

## 分区 ##
Partition() {
	BoG "(1/5)=========> Partition\033[0m"
	FLAG=0
	G "> Adjust partition"
	Y "Do you want to partition your disk?"
	N "  `BoW \"Press [ p ]\"`  to partition\n"
	N "  `BoW \"Press [ n ]\"`  for no"
	read -n1 -s TMP
	N
	if [ "$TMP" == c ]; then
		UserCommand
		if [ "$?" == 0 ]; then
			Partition
			return
		else
			ERROR
			continue
		fi
	elif [ "$TMP" == p ]; then
		while [ true ]; do
			fdisk -l
			G "> Select disk"
			Y "Input disk which you want to partition: `BoW \"/dev/sdX[X: a,b,c,...]\"`"
			read -p "> " DISK
			cfdisk $DISK
			while [ true ]; do
				Y "Continue to partition?"
				N "  `BoW \"Press [ p ]\"`  to partition again\n"
				N "  `BoW \"Press [ n ]\"`  for no"
				read -n1 -s TMP
				N
				if [ "$TMP" == c ]; then
					UserCommand
					if [ "$?" == 1 ]; then
						ERROR
					fi
				elif [ "$TMP" == p ]; then
					break
				elif [ "$TMP" == n ]; then
					FLAG=1
					break
				fi
			done
			if [ "$FLAG" == 1 ]; then
				FLAG=0
				break
			fi
		done
	fi
	G "> Partition done!"
	N
	N
}

## 挂载 ##
MountPartition() {
	G "> Set mount point"
	PARTITION=""
	if [ "$1" == "/mnt" ]; then
		TMP=y
	else
		while [ true ]; do
			Y "Create a `WoY \"$1\"` mount point?"
			N "  `BoW \"Press [ y ]\"`  to Create\n"
			N "  `BoW \"Press [ n ]\"`  for no"
			read -n1 -s TMP
			N
			if [ "$TMP" == c ]; then
				UserCommand
				if [ "$?" == 1 ]; then
					ERROR
				fi
			elif [ "$TMP" == y ]; then
				mkdir $1
				break
			elif [ "$TMP" == n ]; then
				return
			else
				ERROE
			fi
		done
	fi
	while [ "$TMP" == y ]; do
		if [ "$PARTITION"  == "" ]; then
			fdisk -l
			Y "Input the mount point of $1"
			read -p "> " PARTITION
		fi
		## SWAP
		if [ "$1" == "swap" ]; then
			Y "Will swapon $PARTITION"
			N "  `BoW \"Press [ r ]\"`  to change swap partition\n"
			N "  `BoW \"Press [ m ]\"`  to mkswap and swapon"
			read -n1 -s TMP
			N
			if [ "$TMP" == c ]; then
				UserCommand
				if [ "$?" == 1 ]; then
					ERROR
				fi
				TMP=y
			elif [ "$TMP" == r ]; then
				PARTITION=""
				TMP=y
			elif [ "$TMP" == m ]; then
				mkswap $PARTITION
				swapon $PARTITION
				break
			else
				ERROR
				TMP=y
			fi
		## NOT SWAP
		else
			Y "$1 will be mounted on $PARTITION"
			N "  `BoW \"Press [ r ]\"`  to change mount point\n"
			if [ "$1" == "/mnt" -o "$1" == "/mnt/home" ]; then
				N "  `BoW \"Press [ e ]\"`  to format it to ext4\n"
				N "  `BoW \"Press [ b ]\"`  to format it to btrfs\n"
			elif [ "$1" == "/mnt/boot" ]; then
				N "  `BoW \"Press [ f ]\"`  to format it to fat32\n"
			fi
			N "  `BoW \"Press [ m ]\"`  to mount $1 on $PARTITION and done"
			read -n1 -s TMP
			N
			if [ "$TMP" == c ]; then
				UserCommand
				if [ "$?" == 1 ]; then
					ERROR
				fi
				TMP=y
			elif [ "$TMP" == r ]; then
				TMP=y
				PARTITION=""
			elif [ "$TMP" == e ] && ([ "$1" == "/mnt" ] || [ "$1" == "/mnt/home" ] || ([ "$1" != "/mnt" ] && [ "$1" != "/mnt/boot" ] && [ "$1" != "/mnt/home" ])); then
				mkfs.ext4 $PARTITION
				TMP=y
			elif [ "$TMP" == b ] && ([ "$1" == "/mnt" ] || [ "$1" == "/mnt/home" ] || ([ "$1" != "/mnt" ] && [ "$1" != "/mnt/boot" ] && [ "$1" != "/mnt/home" ])); then
				mkfs.btrfs $PARTITION -f
				TMP=y
			elif [ "$TMP" == f ] && [ "$1" == "/mnt/boot" ] || ([ "$1" != "/mnt" ] && [ "$1" != "/mnt/boot" ] && [ "$1" != "/mnt/home" ]); then
				mkfs.fat -F32 $PARTITION
				TMP=y
			elif [ "$TMP" == m ]; then
				mount $PARTITION $1
			else
				ERROR
				TMP=y
			fi
		fi
	done
}

## 挂载分区 ##
Mount() {
	BoG "(2/5)=========> Mount"
	MountPartition "/mnt"
	MountPartition "/mnt/boot"
	MountPartition "/mnt/home"
	MountPartition "swap"
	while [ true ]; do
		G "> Mount more partitions"
		Y "Input there or press Enter to skip `R \"(One by One!)\"`\033[33m (eg. /mnt/media)"
		read -p "> " TMP
		if [ "$TMP" == "" ]; then
			break
		else
			MountPartition "$TMP"
		fi
	done
	G "> Mount done!"
	N
	N
}

## 软件源 ##
EditMirrorList() {
	BoG "(3/5)=========> Mirror"
	if [ ! -f /etc/pacman.d/mirrorlist.bak ]; then
		Y "Backup /etc/pacman.d/mirrorlist TO /etc/pacman.d/mirrorlist.bak ..."
		cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
	fi
	while [ true ]; do
		Y "Edit /etc/pacman.d/mirrorlist?"
		N "  `BoW \"Press [ z ]\"`  to select China's mirrors only\n"
		N "  `BoW \"Press [ h ]\"`  to use [USTC] [TUNA] [163] mirrors\n"
		N "  `BoW \"Press [ e ]\"`  to edit mirrorlist by yourself with nano\n"
		N "  `BoW \"Press [ u ]\"`  to unselect all mirrors\n"
		N "  `BoW \"Press [ r ]\"`  to restore the mirrors\n"
		N "  `BoW \"Press [ s ]\"`  to see which mirror is in use\n"
		N "  `BoW \"Press [ q ]\"`  to finish editing"
		read -n1 -s TMP
		N
		if [ "$TMP" == c ]; then
			UserCommand
			if [ "$?" == 1 ]; then
				ERROR
			fi
		elif [ "$TMP" == z ]; then
			sed -i '/Score/{/China/!{n;s/^/#/}}' /etc/pacman.d/mirrorlist
		elif [ "$TMP" == h ]; then
			echo -e "\n## China\nServer = http://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch\nServer = http://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch\nServer = http://mirrors.163.com/archlinux/\$repo/os/x86_64\n" >> /etc/pacman.d/mirrorlist
		elif [ "$TMP" == e ]; then
			nano /etc/pacman.d/mirrorlist
		elif [ "$TMP" == u ]; then
			sed -i "s/^\b/#/g" /etc/pacman.d/mirrorlist
		elif [ "$TMP" == r ]; then
			cp /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist
		elif [ "$TMP" == s ]; then
			cat /etc/pacman.d/mirrorlist | grep -v "#"
		elif [ "$TMP" == q ]; then
			break
		else
			ERROR
		fi
	done
	echo -e "> Mirror done"
	N
	N
}

## 安装基本系统 ##
InstallBaseSystem() {
	BoG "(4/5)=========> Install the Base Packages"
	INSTALL=1
	while [ true ]; do
		if [ "$INSTALL" == 1 ]; then
			INSTALL=0
			pacstrap /mnt base base-devel --force
		fi
		Y "Successfully installed?"
		N "  `BoW \"Press [   n   ]\"`  to reinstall\n"
		N "  `BoW \"Press [ Enter ]\"`  to next step"
		read -n1 -s TMP
		N
		if [ "$TMP" == c ]; then
			UserCommand
			if [ "$?" == 1 ]; then
				ERROR
			fi
		elif [ "$TMP" == n ]; then
			INSTALL=1
		elif [ "$TMP" == "" ]; then
			break
		else
			ERROR
		fi
	done
	G "> Install the Base Packages done"
	N
	N
}

## 配置系统 ##
ConfigureSystem() {
	BoG "(5/5)=========> Configure the System"
	G "> Fstab"
	if [ -e /mnt/etc/fstab ]; then
		N "\n\033[41;37m[WARN]\033[0;31m  /mnt/etc/fstab exists, make sure there are no errors in fstab file\033[0m"
		Y "    Double click \"C\" key, get into bash and Use \"cat /mnt/etc/fstab\" to see fstab file and check it"
		Y "    If you don't know how to fix this, please \033[43;37mPress [ f ]\033[0;33m to remove it and re-genfstab auto\n"
	else
		genfstab -U /mnt >> /mnt/etc/fstab
	fi
	while [ true ]; do
		Y "Make sure the fstab file is OK"
		N "  `BoW \"Press [ e ]\"`  to edit fstab file with nano\n"
		N "  `BoW \"Press [ n ]\"`  to next step"
		read -n1 -s TMP
		N
		if [ "$TMP" == c ]; then
			UserCommand
			if [ "$?" == 1 ]; then
				ERROR
			fi
		elif [ "$TMP" == e ]; then
			nano /mnt/etc/fstab
		elif [ "$TMP" == f ]; then
			while [ true ]; do
				N "  \033[41;37m[WARN]\033[0;31m]  Will delete fstab file and re-genfstab! Continue if you know what you're doing\033[0m"
				N "  \033[43;37mInput [  yes  ]\033[0;33m  to delete fstab file and re-genfstab\033[0m\n"
				N "  \033[43;37mPress [ Enter ]\033[0;33m  to cancel\033[0m"
				read -p "> " TMP
				echo ""
				if [ "$TMP" == "yes" ]; then
					rm -f /mnt/etc/fstab
					genfstab -U /mnt >> /mnt/etc/fstab
				elif [ "$TMP" == "" ]; then
					break
				else
					ERROR
				fi
			done
		elif [ "$TMP" == n ]; then
			break
		else
			ERROR
		fi
	done
}

main() {
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
	echo -e "\n\n\n\n\n\033[?25h"
	Partition
	Mount
	EditMirrorList
	InstallBaseSystem
	ConfigureSystem

	## Chroot
	Y "> Change root into the new system now\n"
	wget https://raw.githubusercontent.com/youthug/Arch-Installer/master/config.sh -O /mnt/root/config.sh
	chmod +x /mnt/root/config.sh
	arch-chroot /mnt /root/config.sh
}

main
