#!/bin/bash

# Colorful print!
# Normal
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
# White on Black
BoW() {
	echo -e "\033[47;37m$1\033[0m"
}
# White on Green
WoG() {
	echo -e "\033[42;37m$1\033[0m"
}
# White on Yellow
WoY() {
	echo -e "\033[43;37m$1\033[0m"
}
# White on Red
WoR() {
	echo -e "\033[41;37m$1\033[0m"
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
		echo -e "\n\n\033[33mGet into bash now. Input 'exit' to exit bash\033[0m"
		bash
		return 0
	else
		STMP=c"$TMP0"
		return 1
	fi
}


Y "> Change root into the new system!"

## 时区设置
SetLocale() {
	G "> Locale"
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
					Y "Get into trouble? If you don't find a right zone:"
					N "  `BoW \"Input [ back  ]\"` to uplevel"
					N "  `BoW \"Press [ Enter ]\"` to choose again"
					read -p "> " TMP
					if [ "$TMP" == "back" ]; then
						SetLocale
						return
					fi
				elif [ -e /usr/share/zoneinfo/$AREA/$ZONE ]; then
					G "> Set up locale to $AREA/$ZONE"
					ln -sf /usr/share/zoneinfo/$AREA/$ZONE /etc/localtime
					return
				elif [ "$ZONE" == "$AREA" ]; then
					G "> Set up locale to $AREA"
					ln -sf /usr/share/zoneinfo/$AREA /etc/localtime
					return
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
	done
	hwclock --systohc --utc
	Y "Chose your language:"
	select LANG in "en_US.UTF-8" "zh_CN.UTF-8"; do
		if [ "$LANG" "" ]; then
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
	G "> Hostname"
	Y "Input your hostname:"
	read -p "> " NAME
	echo $NAME > /etc/hostname
	G "> Change your password"
	passwd
}

## GRUB
InstallGrub() {
	G "> GRUB"
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
	G "> Bootctl"
	if (mount | grep efivarfs > /dev/null 2>&1); then
		bootctl --path=esp install
		bootctl --path=esp update
	else
		while [ true ]; do
			Y "It seems that your computer's boot mode is not UEFI. Do you want to use grub"
			N "  `BoW \"Press [ q ]\"`  to exit\n"
			N "  `BoW \"Press [ g ]\"`  to use grub"
			read -n1 -s TMP
			echo ""
			if [ "$TMP" == c ]; then
				UserCommand
				if [ "$?" == 0 ]; then
					continue
				else
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
	G "> Add User"
	Y "Input your username(NO UPPERCASE)"
	read -p "> " USER
	useradd -m -g wheel $USER
	Y "Change your password"
	passwd $USER
	pacman -S --noconfirm sudo
	sed -i 's/\# \%wheel ALL=(ALL) ALL/\%wheel ALL=(ALL) ALL/g' /etc/sudoers
    sed -i 's/\# \%wheel ALL=(ALL) NOPASSWD: ALL/\%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers
}

## 显卡驱动
InstallGraphic() {
	G "> Graphic Card"
	Y "What is your graphic card?"
	select CARD in "Intel" "Nvidia" "Intel and Nvidia" "AMD"; do
		case $CARD in
		"Intel")
			pacman -S --noconfirm xf86-video-intel
			break
			;;
		"Nvidia")
			Y "Select version of your Nvidia-card"
			select NVIDIA in "GeForce-8 and newer" "GeForce-6/7" "Older"; do
				case $NVIDIA in
				"GeForce-8 and newer")
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
			select NVIDIA in "GeForce-8 and newer" "GeForce-6/7" "Older"; do
				case $NVIDIA in
				"GeForce-8 and newer")
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
	G "> Bluetooth"
	Y "Do you have a bluetooth?"
	N "  `BoW \"Press [ y ]\"`  to install bluez\n"
	N "  `BoW \"Press [ n ]\"`  for no"
	read -n1 -s TMP
	echo ""
	if [ "$TMP" == c ]; then
		if [ "$?" == 0 ]; then
			InstallBluetooth
			return
		else
			ERROR
		fi
	elif [ "$TMP" == n ]; then
		return
	elif [ "$TMP" == y ]; then
		echo -n ""
	else
		ERROR
		InstallBluetooth
		return
	fi
	pacman -S --noconfirm bluez
	systemctl enable bluetooth
	while [ true ]; do
		Y "Install blueman?"
		N "  `BoW \"Press [ y ]\"`  to install\n"
		N "  `BoW \"Press [ n ]\"`  for no"
		read -n1 -s TMP
		echo ""
		if [ "$TMP" == c ]; then
			if [ "$?" == 0 ]; then
				continue
			else
				ERROR
			fi
		elif [ "$TMP" == y ]; then
			pacman -S --noconfirm blueman
		elif [ "$TMP" == n ]; then
			break
		else
			ERROR
		fi
	done
}

## 安装应用
InstallApp() {
	G "> Application"
	Y "Do you want to use AUR(China)?"
	N "  `BoW \"Press [ y ]\"`  for yes\n"
	N "  `BoW \"Press [ n ]\"`  for no"
	read -n1 -s TMP
	echo ""
	if [ "$TMP" == c ]; then
		if [ "$?" == 0 ]; then
			InstallApp
			return
		else
			ERROR
		fi
	elif [ "$TMP" == y ]; then
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
	pacman -S --noconfirm networkmanager xorg-server firefox wqy-zenhei
	systemctl enable NetworkManager
}

## 桌面环境
InstallDesktop() {
	G "> Desktop"
	Y "Choose a Desktop Environment you want to use"
	select DESKTOP in "Gnome" "KDE" "Xfce" "Cinnamon" "Mate" "Deepin" "Budgie" "Lxde" "Lxqt" "I do not want to install them now"; do
		case $DESKTOP in
		"Gnome")
			pacman -S gnome gnome-terminal
			systemctl enable gdm
			break
			;;
		"KDE")
			pacman -S plasma kdebase kdeutils kdegraphics kde-l10n-zh_cn sddm
			systemctl enable sddm
			break
			;;
		"Xfce")
			pacman -S xfce4 xfce4-goodies xfce4-terminal lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			break
			;;
		"Cinnamon")
			pacman -S cinnamon gnome-terminal lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			break
			;;
		"Mate")
			pacman -S mate mate-extra mate-terminal lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			break
			;;
		"Deepin")
			pacman -S deepin deepin-extra deepin-terminal lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			sed -i '108s/#greeter-session=example-gtk-gnome/greeter-session=lightdm-deepin-greeter/' /etc/lightdm/lightdm.conf
			break
			;;
		"Budgie")
			pacman -S budgie-desktop gnome-terminal lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			break
			;;
		"Lxde")
			pacman -S lxde lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			break
			;;
		"Lxqt")
			pacman -S lxqt lightdm lightdm-gtk-greeter
			systemctl enable lightdm
			break
			;;
		"I do not want to install them now")
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
		G "> Boot Manager"
		Y "Use GRUB or Bootctl"
		N "  `BoW \"Press [ g ]\"`  to use GRUB\n"
		N "  `BoW \"Press [ b ]\"`  to use Bootctl"
		read -n1 -s TMP
		echo ""
		if [ "$TMP" == c ]; then
			UserCommand
			if [ "$?" == 0 ]; then
				continue
			else
				ERROR
				continue
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
	G "\n\nALL have done! Try it now."
}

main