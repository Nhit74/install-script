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
  echo 'do you want a swap partition?'
  echo 1- yes
  echo 2- no
  read -p "Type 1 or 2: " swap
  if [ $swap -eq 1 ]
  then
    read -p "Where is your swap partition? " swap_route
    mkswap $swap_route
    swapon $swap_route
  fi
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
  read -p "Select your kernel: " kernel
  pacstrap -K /mnt base $kernel linux-firmware
  echo "Base sistem installed"
  sleep 2
  genfstab -U /mnt >> /mnt/etc/fstab
  echo "fstab created remeaber to check it"
  cp install.sh  /mnt/install.sh
  echo 'run the script another time'
  sleep 2
  arch-chroot /mnt
fi
echo 'wellcome to arch-chroot'
echo 'select your area and loaction'
read -p "Area: " area
read -p "Location: " loaction
ln -sf /usr/share/zoneinfo/$area/$loaction /etc/loacltime
hwclock --systohc
echo 'time succesfuly selected'
sleep 1
clear
locale-gen
echo 'select your locales'
read -p "type your locale: " loacle
echo LANG=$locale >> /etc/loacle.conf
sleep 3
echo 'select your keyboard lenguage'
read -p "keyboard: " keys
echo KEYMAP=$keys > /etc/vconsole.conf
echo keyboard succesfull configured
sleap 1
clear
read -p 'type your hostname: ' host
echo $host > /etc/hostname
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
echo "Recomended software"
echo 1- networkmanager sudo nano
echo 2- no more software
read -p "Chose one option: " soft
if [ $soft -eq 1 ]
then
  pacman -S networkmanager sudo nano
fi
clear
echo "Please create a user"
echo 1- "Yes, I want a user."
echo 2- "No, I don't want a user"
read -p "Chose one or two: " YoN
if [ $YoN -eq 1 ]
then
  read -p "Username: " user
  useradd -m -s /bin/bash $user
  passwd $user
  echo "user created"
  echo "Now you have arch linux! Exit chroot and reboot."
fi
