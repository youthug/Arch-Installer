#!/bin/bash

## 2018-02-27 13:26

N() {
	echo -e "$1"
	if [ "$2" == n ]; then
		echo ""
	fi
}
# Green
G() {
	echo -e "\033[32m$1\033[0m"
	if [ "$2" == n ]; then
		echo ""
	fi
}
# Yellow
Y() {
	echo -e "\033[33m$1\033[0m"
	if [ "$2" == n ]; then
		echo ""
	fi
}
R() {
	echo -e "\033[31m$1\033[0m"
	if [ "$2" == n ]; then
		echo ""
	fi
}
# Black on White
BoW() {
	echo -e "\033[47;30m$1\033[0m"
	if [ "$2" == n ]; then
		echo ""
	fi
}
# Black on Green
BoG() {
	echo -e "\033[42;30m$1\033[0m"
	if [ "$2" == n ]; then
		echo ""
	fi
}
# White on Yellow
WoY() {
	echo -e "\033[43;37m$1\033[0m"
	if [ "$2" == n ]; then
		echo ""
	fi
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
	BoG "(1/5)=========> Partition" n
	FLAG=0
	G "> Adjust partition" n
	Y "Do you want to partition your disk?" n
	N "  `BoW \"Press [ p ]\"`  to partition" n
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
			N
			Y "Input the disk which you want to partition: `BoW \"/dev/sdX[X: a,b,c,...]\"`"
			read -p "> " DISK
			cfdisk $DISK
			while [ true ]; do
				Y "Continue to partition?" n
				N "  `BoW \"Press [ p ]\"`  to partition again" n
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
	G "> Partition done!" n
	N
}

## 挂载 ##
MountPartition() {
	G "> Set mount point" n
	PARTITION=""
	if [ "$1" == "/mnt" ]; then
		TMP=y
	else
		while [ true ]; do
			Y "Create a `WoY \"$1\"`\033[0;33m mount point?" n
			N "  `BoW \"Press [ y ]\"`  to Create" n
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
			Y "Will swapon $PARTITION" n
			N "  `BoW \"Press [ r ]\"`  to change swap partition" n
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
			Y "$1 will be mounted on $PARTITION" n
			N "  `BoW \"Press [ r ]\"`  to change mount point" n
			if [ "$1" == "/mnt" -o "$1" == "/mnt/home" ]; then
				N "  `BoW \"Press [ e ]\"`  to format it to ext4" n
				N "  `BoW \"Press [ b ]\"`  to format it to btrfs" n
			elif [ "$1" == "/mnt/boot" ]; then
				N "  `BoW \"Press [ f ]\"`  to format it to fat32" n
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
				Y "  Format EFI partition! You may not be able to boot up other OS which had been installed!\nInput \"yes\" to farmat it if you know what you are doing"
				read -p "> " TMP
				if [ "$TMP" == "yes" ]; then
					mkfs.fat -F32 $PARTITION
				fi
				TMP=y
			elif [ "$TMP" == m ]; then
				mount $PARTITION $1
				break
			else
				ERROR
				TMP=y
			fi
		fi
	done
}

## 挂载分区 ##
Mount() {
	BoG "(2/5)=========> Mount" n
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
	G "> Mount done!" n
	N
}

## 软件源 ##
EditMirrorList() {
	BoG "(3/5)=========> Mirror" n
	if [ ! -f /etc/pacman.d/mirrorlist.bak ]; then
		Y "Backup /etc/pacman.d/mirrorlist TO /etc/pacman.d/mirrorlist.bak" n
		cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
	fi
	sed -i "s/^\b/#/g" /etc/pacman.d/mirrorlist
	Y "All mirrors have been commented out(unselect). Now choose the mirrors you want to use." n
	while [ true ]; do
		Y "Edit /etc/pacman.d/mirrorlist?" n
		N "  `BoW \"Press [ z ]\"`  to select China's mirrors only" n
		N "  `BoW \"Press [ h ]\"`  to use [USTC] [TUNA] [163] mirrors" n
		N "  `BoW \"Press [ e ]\"`  to edit mirrorlist by yourself with nano" n
		N "  `BoW \"Press [ u ]\"`  to unselect all mirrors" n
		N "  `BoW \"Press [ r ]\"`  to restore mirrorslist" n
		N "  `BoW \"Press [ s ]\"`  to see what is being used" n
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
			echo -e "\n\n## China\n## [USTC]\nServer = http://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch\n## [TUNA]\nServer = http://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch\n## [163]\nServer = http://mirrors.163.com/archlinux/\$repo/os/x86_64\n" >> /etc/pacman.d/mirrorlist
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
	echo -e "> Mirror done" n
	N
}

## 安装基本系统 ##
InstallBaseSystem() {
	BoG "(4/5)=========> Install the Base Packages" n
	INSTALL=1
	while [ true ]; do
		if [ "$INSTALL" == 1 ]; then
			INSTALL=0
			pacstrap /mnt base base-devel --force
		fi
		Y "Successfully installed?"
		N "  `BoW \"Press [   n   ]\"`  to reinstall" n
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
	BoG "(5/5)=========> Configure the System" n
	G "> GenFstab"
	cp /mnt/etc/fstab /mnt/etc/fstab.bak
	genfstab -U /mnt >> /mnt/etc/fstab
	while [ true ]; do
		cat -n /mnt/etc/fstab
		Y "Make sure the fstab file is OK" n
		N "  `BoW \"Press [ e ]\"`  to edit fstab file with nano" n
		N "  `BoW \"Press [ r ]\"`  to restore /etc/fstab and re-genfstab" n
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
		elif [ "$TMP" == r ]; then
			cat /mnt/etc/fstab.bak > /mnt/etc/fstab
			genfstab -U /mnt >> /mnt/etc/fstab
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

	echo -ne "\033[32mYou can click 'C' double time to get into bash in front of every input line.

eg.\033[0m
  ...
  \033[47;30mPress [ * ]\033[0m  to ...
\033[33m[Double click 'C' key]
\033[32m> Get into bash now. Input 'exit' to exit bash\033[0m

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
	G "> Downloading config.sh..." n
	wget https://raw.githubusercontent.com/youthug/Arch-Installer/master/config.sh -O /mnt/root/config.sh
	chmod +x /mnt/root/config.sh
	G "> Change root into the new system now" n
	arch-chroot /mnt /root/config.sh
}

main
