#!/bin/bash

echo -e "\033[33m(FILE : config.sh)
\033[0m"
read -p "Press Enter to continue ..."

## 必要设置
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc
echo "zh_CN.UTF-8 UTF-8
zh_TW.UTF-8 UTF-8
en_US.UTF-8 UTF-8
" >> /etc/locale.gen
## echo Edit /etc/locale.gen ...
## nano /etc/locale.gen
locale-gen
echo LANG=zh_CN.UTF-8 > /etc/locale.conf
echo -e "\033[33mInput yout hostname : \033[0m"
read HOSTNAME
echo $HOSTNAME > /etc/hostname
echo Change yout root password
passwd
## 安装引导
echo -e "\033[32mDo you use efi to boot ?
\033[0m"
read -p "(y or Enter to install legacy boot support : " TMP
if [ "$TMP" == y ]
then
	TMP=n
	while [ "$TMP" == n ]
	do
		pacman -S --noconfirm grub efibootmgr os-prober -y
		grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchLinux
		grub-mkconfig -o /boot/grub/grub.cfg
	echo -e "\033[33mSuccessfully installed ?
\033[0m"
	read -p "(Input n to re-install, or press Enter to continue : " TMP
	done
else
	TMP=n
	while [ "$TMP" == n ]
	do
		pacman -S --noconfirm grub os-prober -y&&fdisk -l
		echo -e "\033[33mInput the disk which you want to install the grub : \033[0m"
		read GRUB
		grub-install --target=i386-pc $GRUB
		grub-mkconfig -o /boot/grub/grub.cfg
		echo -e "\033[33mSuccessfully installed ?
\033[0m"
		read -p "(Input n to re-install or press Enter to continue : " TMP
	done
fi
## 安装显卡驱动
TMP=n
while [ "$TMP" == n ]
do
	VIDEO=5
	##while [ $VIDEO!=1&&$VIDEO!=2&&$VIDEO!=3&&$VIDEO!=4 ]
	while (($VIDEO!=1&&$VIDEO!=2&&$VIDEO!=3&&$VIDEO!=4));
	do
		echo -e "\033[32mSelect your video card :
\033[0m"
		echo "  [1] Intel
  [2] NVIDIA
  [3] Intel and NVIDIA
  [4] AMD and ATI
: "
		read VIDEO
		if [ $VIDEO == 1 ]
		then
			pacman -S --noconfirm xf86-video-intel -y
		elif [ $VIDEO == 2 ]
		then
			VERSION=4
			while (($VERSION!=1&&$VERSION!=2&&$VERSION!=3));
			do
				echo -e "\033[32mSelect the version of NVIDIA-Driver to install :
\033[0m"
				echo "  [1] GeForce-8 or newer
  [2] GeForce-6/7
  [3] Older
: "
				read VERSION
				if [ $VERSION == 1 ]
				then
					pacman -S --noconfirm nvidia -y
				elif [ $VERSION == 2 ]
				then
					pacman -S --noconfirm nvidia-340xx -y
				elif [ $VERSION == 3 ]
				then
					pacman -S --noconfirm nvidia-304xx -y
				else
					echo -e "\033[31mError ! Input the number again : \033[0m"
				fi
			done
		elif [ $VIDEO == 3 ]
		then
			pacman -S --noconfirm bumblebee xf86-video-intel -y
			systemctl enable bumblebeed
			VERSION=4
			while (($VERSION!=1&&$VERSION!=2&&$VERSION!=3));
			do
				echo -e "\033[32mSelect the version of NVIDIA-Driver to install :
\033[0m"
				echo "  [1] GeForce-8 or newer
  [2] GeForce-7/8
  [3] Older
: "
				read VERSION
				if [ $VERSION == 1 ]
				then
					pacman -S --noconfirm nvidia -y
				elif [ $VERSION == 2 ]
				then
					pacman -S --noconfirm nvidia-340xx -y
				elif [ $VERSION == 3 ]
				then
					pacman -S --noconfirm nvidia-304xx -y
				else
					echo -e "\033[31mError ! Input the number again : \033[0m"
				fi
			done
		elif [ $VIDEO == 4 ]
		then
			pacman -S --noconfirm xf86-video-ati -y
		else
			echo -e "\033[31mError ! Input the number again : \033[0m"
		fi
	done
	echo -e "\033[33mSuccessful installed ?
\033[0m"
	read -p "(Input n to re-install or press Enter to continue : " TMP
done
## 安装必要软件/简单配置
echo "[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch" >> /etc/pacman.conf
TMP=n
while [ "$TMP" == n ]
do
	pacman -Syu&&pacman -S archlinuxcn-keyring&&pacman -S networkmanager dialog iw wpa_supplicant netctl wireless_tools xorg-server yaourt wqy-zenhei sudo firefox firefox-i18n-zh-cn fcitx-sogoupinyin
	systemctl enable NetworkManager
	echo -e "\033[32mDo you hava bluetooth ?
\033[0m"
	read -p "(y or Enter to skip : " TMP
	if [ "$TMP" == y ]
	then
		pacman -S bluez blueman&&systemctl enable bluetooth
	fi
	echo -e "\033[33mSuccessful installed ?
\033[0m"
	read -p "(Input n to re-install or press Enter to continue : " TMP
done
## 安装桌面环境
TMP=n
while [ "$TMP" == n ]
do
	echo -e "\033[32mWhick Desktop Environment do you want to install :
\033[0m"
	DESKTOP=0
	while (($DESKTOP!=1&&$DESKTOP!=2&&$DESKTOP!=3&&$DESKTOP!=4&&$DESKTOP!=5&&$DESKTOP!=6&&$DESKTOP!=7&&$DESKTOP!=8&&$DESKTOP!=9));
	do
echo "  [1]  Gnome
  [2] Kde
  [3] Lxde
  [4] Lxqt
  [5] Mate
  [6] Xfce
  [7] Deepin
  [8] Budgie
  [9] Cinnamon
  [10] i3wm
: "
		read DESKTOP
		case $DESKTOP in
		1) pacman -S gnome
		;;
		2) pacman -S plasma kdebase kdeutils kdegraphics kde-l10n-zh_cn sddm
		;;
		3) pacman -S lxde lightdm lightdm-gtk-greeter
		;;
		4) pacman -S lxqt lightdm lightdm-gtk-greeter
		;;
		5) pacman -S mate mate-extra lightdm lightdm-gtk-greeter
		;;
		6) pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
		;;
		7) pacman -S deepin deepin-extra lightdm lightdm-gtk-greeter&&sed -i '108s/#greeter-session=example-gtk-gnome/greeter-session=lightdm-deepin-greeter/' /etc/lightdm/lightdm.conf
		;;
		8) pacman -S budgie-desktop lightdm lightdm-gtk-greeter
		;;
		9) pacman -S cinnamon lightdm lightdm-gtk-greeter
		;;
		10) pacman -S i3 rofi rxvt-unicode lightdm lightdm-gtk-greeter
		;;
		*) echo -e "\033[31mError ! Input the number again : \033[0m"
		;;
		esac
	done
	echo -e "\033[33mSuccessfully installed ?
\033[0m"
	read -p "(Input n to re-install or press Enter to continue : " TMP
done
## 建立用户
echo -e "\033[32mInput a Username you want to use : \033[0m"
read USER
useradd -m -g wheel $USER
# useradd -m -g wheel -s /usr/bin/bash $USER
passwd $USER
usermod -aG root,bin,daemon,tty,disk,games,network,video,audio $USER
if [ $VIDEO == 3 ]
then
	gpasswd -a $USER bumblebee
fi
if [ $DESKTOP == 1 ]
then
	gpasswd -a $USER gdm
	systemctl enable gdm
elif [ $DESKTOP == 2 ]
then
	gpasswd -a $USER sddm
else
	gpasswd -a $USER lightdm
	systemctl enable lightdm
fi
sed -i 's/\# \%wheel ALL=(ALL) ALL/\%wheel ALL=(ALL) ALL/g' /etc/sudoers
## 自定义
echo -e "\033[32mInput your own command OR input exit to quit : \033[0m"
bash
echo -e "\033[32mInstalltion is complete !
\" Hello Linux! \"\033[0m"
