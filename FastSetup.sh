#!/bin/bash

echo INSTALL_ARCH
echo ""
echo "select if you are in chroot or not"
echo 1- NO chroot
echo 2- chroot
read -p "Chose one or two: " place
if [ $place -eq 1 ]
then
  timedatectl

  fdisk -l
  read -p "Select the media for make partitions: " media
  fdisk $media
  read -p "Select your boot partition: " boot
  read -p "Select your Linux partition: " linux
  mkfs.fat -F 32 $boot
  mkfs.ext4 $linux
  echo 'Format done'
  clear
  echo "Mounting the sistem"
  mount $linux /mnt
  mount --mkdir $boot /mnt/boot
  echo "Syestem mounted"
  echo "Select your mirrors"
  sleep 2
  nano /etc/pacman.d/mirrorlist
  echo "Mirrors selected"
  pacstrap -K /mnt base linux linux-firmware
  echo "Base sistem installed"
  sleep 2
  genfstab -U /mnt >> /mnt/etc/fstab
  echo "fstab created remeaber to check it"
  cp FastSetup.sh  /mnt/FastSetup.sh
  chmod +x /mnt/FastSetup.sh
  echo 'run the script another time'
  sleep 2
  arch-chroot /mnt
  ./FastSetup.sh
fi
echo 'wellcome to arch-chroot'
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/loacltime
hwclock --systohc
echo 'time succesfuly selected'
sleep 1
clear
locale-gen
echo LANG=ES_es.UTF-8 >> /etc/loacle.conf
sleep 3
echo 'select your keyboard lenguage'
echo KEYMAP=es > /etc/vconsole.conf
echo keyboard succesfull configured
sleep 1
clear
echo Autoarch > /etc/hostname
echo create a root passwd
passwd
clear
echo ""
echo "Bootloader (grub)"
echo ""
sleep 2
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
sleep 3
echo ""
echo "Grub installed"
sleep 2
pacman -S networkmanager sudo nano
sleep 2
clear
echo "Please create a user"
useradd -m -s /bin/bash Admin
passwd Admin
echo "user created"
clear
usermod -aG wheel Admin
echo "Modify the sudoers file and uncoment the wheel group"
EDITOR=nano sudo visudo
