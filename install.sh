#!/bin/bash
echo INSTALL_ARCH
echo ""
echo "select if you are in chroot or not"
echo "[ 1 ] NO chroot"
echo "[ 2 ] chroot"
read -p "Tyrpe "1" or "2", then press enter: " place
if [ "$place" -eq 1 ]
then
  timedatectl

  fdisk -l
  read -p "Select the media for make partitions: " media
  fdisk "$media"
  read -p "Select your boot partition: " boot
  read -p "Select your Linux partition: " linux
  echo 'do you want a swap partition?'
  echo 1- yes
  echo 2- no
  read -p "Type y or N, then pres enter: " swap
  if [ "$swap" == "y" ]
  then
    read -p "Where is your swap partition? " swap_route
    mkswap "$swap_route"
    swapon "$swap_route"
  fi
  mkfs.fat -F 32 "$boot"
  mkfs.ext4 "$linux"
  echo 'Format done'
  clear
  echo "Mounting the sistem"
  mount "$linux" /mnt
  mount --mkdir "$boot" /mnt/boot
  echo "System mounted"
  echo "Select your mirrors"
  sleep 2
  nano /etc/pacman.d/mirrorlist
  echo "Mirrors selected"
  clear
  echo ""
  echo "[ 1 ] Linux"
  echo "[ 2 ] Linux lts"
  echo "[ 3 ] Linux zen"
  read -p "Select your kernel: " kopt
  case "$kopt" in
    1) kernel="linux" ;;
    2) kernel="linux-lts" ;;
    3) kernel="linux-zen" ;;
    *) kernel="linux" ;;
  esac
  pacstrap -K /mnt base "$kernel" linux-firmware
  echo "Base sistem installed"
  sleep 2
  genfstab -U /mnt >> /mnt/etc/fstab
  echo "fstab created, check it"
  cp install.sh  /mnt/install.sh
  chmod +x /mnt/install.sh
  echo 'run the script another time'
  sleep 2
  arch-chroot /mnt
elif [ "$place" -eq 2 ]
then
  echo 'wellcome to arch-chroot'
  echo 'select your area and location'
  read -p "Area: " area
  read -p "Location: " loaction
  ln -sf /usr/share/zoneinfo/$area/$loaction /etc/localtime
  hwclock --systohc
  echo 'time succesfuly selected'
  sleep 1
  clear
  echo 'select your locales'
  echo "es_ES.UTF-8"
  echo "ca_ES.UTF-8"
  read -p "type your locale: " locale
  echo LANG="$locale" > /etc/locale.conf
  locale-gen
  sleep 3
  echo "select your keyboard lenguage"
  read -p "keyboard: " keys
  echo KEYMAP="$keys" > /etc/vconsole.conf
  echo "keyboard succesfull configured"
  sleep 1
  clear
  read -p "type your hostname: " host
  echo "$host" > /etc/hostname
  echo create a root passwd
  passwd
  clear
  echo ""
  echo "Bootloader (grub)"
  echo ""
  sleep 2
  pacman -S --noconfirm grub efibootmgr
  mkdir /boot/grub
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  grub-mkconfig -o /boot/grub/grub.cfg
  sleep 3
  echo ""
  echo "Grub installed"
  sleep 2
  echo "Do you want networkmanager, sudo and nano? "
  read -p "Type y or N, then pres enter: " soft
fi
if [ "$soft" == "y" ]
then
  pacman -S --noconfirm networkmanager sudo nano
  systemctl enable NetworkManager
fi
clear
echo "Do you want a user?"
read -p "Type y or N, then pres enter: " YoN
if [ "$YoN" == "y" ]
then
  read -p "Username: " user
  useradd -m -s /bin/bash "$user"
  passwd "$user"
  echo "user created"
  echo "Now you have arch linux! Exit chroot and reboot."
  clear
  echo "Do you want to be sudoer?"
  read -p "Type y or N, then pres enter: " SU
  if [ "$SU" == "y" ]
  then
    usermod -aG wheel "$user"
    echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
    chmod 440 /etc/sudoers.d/wheel
  fi
fi
