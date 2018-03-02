#!/bin/bash

# Colorful print!
# Normal
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
# White on Black
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

# Error message
ERROR() {
	if [ "$1" == "" ]; then
		echo -e "\033[41;37mOoops! Command not found. Try again.\033[0m"
	else
		echo -e "\033[41;37m$1\033[0m"
	fi
}
# Get into bash
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

## 时区设置
SetLocale() {
	G "> Set Locale" n
	FLAG=0
	Y "Choose your timezone"
	select AREA in `ls /usr/share/zoneinfo`; do
		echo $AREA
		if [ "$AREA" == "" ]; then
			ERROR
			SetLocale
			return
		elif [ "$AREA" == "+VERSION" ]; then
			ERROR "Not this! Try again."
			SetLocale
			return
		elif [ -d /usr/share/zoneinfo/$AREA ]; then
			select ZONE in `ls /usr/share/zoneinfo/$AREA`; do
				if [ "$ZONE" == "" ]; then
					ERROR
					Y "Get into trouble? If you don't find a right zone there:" n
					N "  `BoW \"Input [ back  ]\"` to uplevel" n
					N "  `BoW \"Press [ Enter ]\"` to choose again" n
					read -p "> " TMP
					if [ "$TMP" == "back" ]; then
						SetLocale
						return
					fi
				elif [ -f /usr/share/zoneinfo/$AREA/$ZONE ]; then
					G "> Set up locale to $AREA/$ZONE"
					ln -sf /usr/share/zoneinfo/$AREA/$ZONE /etc/localtime
					FLAG=1
					break
				else
					ERROR
				fi
			done
			break
		elif [ -f /usr/share/zoneinfo/$AREA ]; then
			G "> Set up locale to $AREA"
			ln -sf /usr/share/zoneinfo/$AREA /etc/localtime
			break
		else
			ERROR
		fi
		if [ "$FLAG" == 1 ]; then
			braek
		fi
	done
	hwclock --systohc --utc
	Y "Chose your language:"
	select LANG in "en_US.UTF-8" "zh_CN.UTF-8"; do
		if [ "$LANG" == "" ]; then
			ERROR
		else
			echo "$LANG UTF-8" > /etc/locale.gen
			locale-gen
			echo LANG=$LANG > /etc/locale.conf
			break
		fi
	done
}

## 主机名
SetHost() {
	G "> Set Hostname" n
	Y "Input your hostname"
	read -p "> " NAME
	echo $NAME > /etc/hostname
	G "> Change password of root"
	passwd
}

## GRUB
InstallGrub() {
	G "> GRUB" n
	if (mount | grep efivarfs > /dev/null 2>&1); then
		pacman -S --noconfirm grub efibootmgr -y
		grub-install --target=`uname -m`-efi --efi-directory=/boot --bootloader-id=Arch-Grub
		grub-mkconfig -o /boot/grub/grub.cfg
	else
		pacman -S --noconfirm grub
		fdisk -l
		Y "Which disk do you want to install grub: (/dev/sdX[X:a,b,...]"
		read -p "> " TMP
		grub-install --target=i386-pc $TMP
		grub-mkconfig -o /boot/grub/grub.cfg
	fi
}

## Bootctl
InstallBootctl() {
	G "> Bootctl" n
	if (mount | grep efivarfs > /dev/null 2>&1); then
		bootctl install
		bootctl update
		sed -i "s/^\b/#/g" /boot/loader/loader.conf
		echo -e "timeout 3\ndefault arch" >> /boot/loader/loader.conf
		fdisk -l
		Y "Which is your ROOT(/) partition?(/dev/sdxY)"
		read -p "> " TMP
		echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=PARTUUID=`blkid -s PARTUUID -o value $TMP` rw" > /boot/loader/entries/arch.conf
		Y "FILE /boot/loader/loader.conf :"
		cat /boot/loader/loader.conf
		Y "FILE /boot/loader/entries/arch.conf :"
		cat /boot/loader/entries/arch.conf
		N
		Y "You'd better check /boot/loader/loader.conf and /boot/loader/entries/arch.conf by yourself." n
	else
		while [ true ]; do
			Y "It seems that your computer's boot mode is not UEFI. We can't install bootctl. Do you want to use grub?" n
			N "  `BoW \"Press [ q ]\"`  to exit" n
			N "  `BoW \"Press [ g ]\"`  to use grub"
			read -n1 -s TMP
			N
			if [ "$TMP" == c ]; then
				UserCommand
				if [ "$?" == 1 ]; then
					ERROR
				fi
			elif [ "$TMP" == q ]; then
				exit
			elif [ "$TMP" == "" ]; then
				InstallGrub
				return
			else
				ERROR
			fi
		done
	fi
}

## 添加用户
AddUser() {
	G "> Add User" n
	Y "Input your username(NO UPPERCASE)"
	read -p "> " USER
	useradd -m -g wheel $USER
	Y "Change password of $USER"
	passwd $USER
	pacman -S --noconfirm sudo
	sed -i 's/\# \%wheel ALL=(ALL) ALL/\%wheel ALL=(ALL) ALL/g' /etc/sudoers
    sed -i 's/\# \%wheel ALL=(ALL) NOPASSWD: ALL/\%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers
}

## 显卡驱动
InstallGraphic() {
	G "> Graphics Card" n
	Y "Select type of your graphics card"
	select CARD in "Intel" "Nvidia" "Intel and Nvidia" "AMD"; do
		case $CARD in
		"Intel")
			pacman -S --noconfirm xf86-video-intel
			break
			;;
		"Nvidia")
			Y "Select version of your Nvidia graphics card"
			select NVIDIA in "GeForce-8 or newer" "GeForce-6/7" "Older"; do
				case $NVIDIA in
				"GeForce-8 or newer")
					pacman -S --noconfirm nvidia
					break
					;;
				"GeForce-6/7")
					pacman -S --noconfirm nvidia-304xx
					break
					;;
				"Older")
					pacman -S --noconfirm nvidia-340xx
					break
					;;
				*)
					ERROR
					;;
				esac
			done
			break
			;;
		"Intel and Nvidia")
			Y "Select version of your Nvidia-card"
			select NVIDIA in "GeForce-8 or newer" "GeForce-6/7" "Older"; do
				case $NVIDIA in
				"GeForce-8 or newer")
					pacman -S --noconfirm nvidia
					break
					;;
				"GeForce-6/7")
					pacman -S --noconfirm nvidia-304xx
					break
					;;
				"Older")
					pacman -S --noconfirm nvidia-340xx
					break
					;;
				*)
					ERROR
					;;
				esac
			done
			pacman -S --noconfirm bumblebee
			systemctl enable bumblebeed
			gpasswd -a $USER bumblebee
			break
			;;
		*)
			ERROR
			;;
		esac
	done
}

## 蓝牙
InstallBluetooth() {
	G "> Bluetooth" n
	Y "Do you have a bluetooth?" n
	N "  `BoW \"Press [ y ]\"`  to install bluez" n
	N "  `BoW \"Press [ n ]\"`  for no"
	read -n1 -s TMP
	N
	if [ "$TMP" == c ]; then
		UserCommand
		if [ "$?" == 0 ]; then
			InstallBluetooth
			return
		else
			ERROR
		fi
	elif [ "$TMP" == n ]; then
		return
	elif [ "$TMP" == y ]; then
		pacman -S --noconfirm bluez
		systemctl enable bluetooth
		while [ true ]; do
			Y "Install blueman?" n
			N "  `BoW \"Press [ y ]\"`  to install" n
			N "  `BoW \"Press [ n ]\"`  for no"
			read -n1 -s TMP
			N
			if [ "$TMP" == c ]; then
				UserCommand
				if [ "$?" == 1 ]; then
					ERROR
				fi
			elif [ "$TMP" == y ]; then
				pacman -S --noconfirm blueman
				break
			elif [ "$TMP" == n ]; then
				break
			else
				ERROR
			fi
		done
	else
		ERROR
		InstallBluetooth
		return
	fi
}

## 安装应用
InstallApp() {
	G "> Application" n
	Y "Do you want to use AUR(yaourt)?" n
	N "  `BoW \"Press [ y ]\"`  for yes" n
	N "  `BoW \"Press [ n ]\"`  for no"
	read -n1 -s TMP
	N
	if [ "$TMP" == c ]; then
		UserCommand
		if [ "$?" == 0 ]; then
			InstallApp
			return
		else
			ERROR
		fi
	elif [ "$TMP" == y ]; then
		Y "Which one you want to use?"
		select AUR in "USTC" "TUNA" "163"; do
			case $AUR in
			"USTC")
				echo -e "[archlinuxcn]\nServer = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch" >> /etc/pacman.conf
				break
				;;
			"TUNA")
				echo -e "[archlinuxcn]\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch" >> /etc/pacman.conf
				break
				;;
			"163")
				echo -e "[archlinuxcn]\nServer = http://mirrors.163.com/archlinux-cn/\$arch" >> /etc/pacman.conf
				break
				;;
			*)
				ERROR
				;;
			esac
		done
		pacman -Sy --noconfirm archlinuxcn-keyring
		pacman -S --noconfirm yaourt
	elif [ "$TMP" == n ]; then
		echo -n ""
	else
		ERROR
	fi
	pacman -S --noconfirm networkmanager xorg-server wqy-zenhei
	systemctl enable NetworkManager
	FLAG=0
	while [ true ]; do
		Y "Install Firefox?" n
		N "  `BoW \"Press [ y ]\"`  for yes" n
		N "  `BoW \"Press [ n ]\"`  for no"
		read -n1 -s TMP
		N
		if [ "$TMP" == c ]; then
			UserCommand
			if  [ "$?" == 1 ]; then
				ERROR
			fi
		elif [ "$TMP" == y ]; then
			pacman -S --noconfirm firefox
			while [ true ]; do
				Y "Install firefox-i18n-zh-cn(Chinese (Simplified) language pack for Firefox)?" n
				N "  `BoW \"Press [ y ]\"`  for yes" n
				N "  `BoW \"Press [ n ]\"`  for no"
				read -n1 -s TMP
				N
				if [ "$TMP" == c ]; then
					UserCommand
					if  [ "$?" == 1 ]; then
						ERROR
					fi
				elif [ "$TMP" == y ]; then
					pacman -S --noconfirm firefox-i18n-zh-cn
					FLAG=1
					break
				elif [ "$TMP" == n ]; then
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
		if [ "$FLAG" == 1 ]; then
			FLAG=0
			break
		fi
	done
	while [ true ]; do
		Y "Install Fcitx?" n
		N "  `BoW \"Press [ y ]\"`  for yes" n
		N "  `BoW \"Press [ n ]\"`  for no"
		read -n1 -s TMP
		N
		if [ "$TMP" == c ]; then
			UserCommand
			if  [ "$?" == 1 ]; then
				ERROR
			fi
		elif [ "$TMP" == y ]; then
			pacman -S --noconfirm fcitx fcitx-configtool
			while [ true ]; do
				Y "Install Sogou Pinyin?" n
				N "  `BoW \"Press [ y ]\"`  for yes" n
				N "  `BoW \"Press [ n ]\"`  for no"
				read -n1 -s TMP
				N
				if [ "$TMP" == c ]; then
					UserCommand
					if  [ "$?" == 1 ]; then
						ERROR
					fi
				elif [ "$TMP" == y ]; then
					pacman -S --noconfirm fcitx-sogoupinyin
					FLAG=1
					break
				elif [ "$TMP" == n ]; then
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
		if [ "$FLAG" == 1 ]; then
			FLAG=0
			break
		fi
	done
}

## 桌面环境
InstallDesktop() {
	G "> Desktop" n
	Y "Choose a Desktop Environment you want to use"
	select DESKTOP in "Gnome" "KDE" "Xfce" "Cinnamon" "Mate" "Deepin" "Budgie" "Lxde" "Lxqt" "I don't want to install them now"; do
		case $DESKTOP in
		"Gnome")
			pacman -S --noconfirm gnome gnome-terminal
			systemctl enable gdm
			break
			;;
		"KDE")
			pacman -S --noconfirm plasma kdebase kdeutils kdegraphics kde-l10n-zh_cn sddm
			systemctl enable sddm
			break
			;;
		"Xfce")
			pacman -S --noconfirm xfce4 xfce4-goodies xfce4-terminal lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			break
			;;
		"Cinnamon")
			pacman -S --noconfirm cinnamon gnome-terminal lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			break
			;;
		"Mate")
			pacman -S --noconfirm mate mate-extra mate-terminal lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			break
			;;
		"Deepin")
			pacman -S --noconfirm deepin deepin-extra deepin-terminal lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			sed -i '108s/#greeter-session=example-gtk-gnome/greeter-session=lightdm-deepin-greeter/' /etc/lightdm/lightdm.conf
			break
			;;
		"Budgie")
			pacman -S --noconfirm budgie-desktop gnome-terminal lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			break
			;;
		"Lxde")
			pacman -S --noconfirm lxde lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			break
			;;
		"Lxqt")
			pacman -S --noconfirm lxqt lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			break
			;;
		"I don't want to install them now")
			break
			;;
		*)
			ERROR
			;;
		esac
	done
}

## main
main() {
	SetLocale
	SetHost
	while [ true ]; do
		G "> Boot Manager" n
		Y "Use GRUB or Bootctl" n
		N "  `BoW \"Press [ g ]\"`  to use GRUB" n
		N "  `BoW \"Press [ b ]\"`  to use Bootctl"
		read -n1 -s TMP
		N
		if [ "$TMP" == c ]; then
			UserCommand
			if [ "$?" == 1 ]; then
				ERROR
			fi
		elif [ "$TMP" == g ]; then
			InstallGrub
			break
		elif [ "$TMP" == b ]; then
			InstallBootctl
			break
		else
			ERROR
		fi
	done
	AddUser
	InstallGraphic
	InstallBluetooth
	InstallApp
	InstallDesktop
	N "\n"
	G "ALL have done! Try it now." n
	bash
}

main
