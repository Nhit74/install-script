#!/bin/bash
echo INSTALL_ARCH
echo ""
echo "Select if you are in arch-chroot or in the main root."
echo "[ 1 ] NO chroot"
echo "[ 2 ] chroot"
read -p "Tyrpe "1" or "2", then press enter: " place
if [ "$place" -eq 1 ] || [ "$place" -eq 2 ]
then
  if [ "$place" -eq 1 ]
  then
    if [ -d /sys/firmware/efi ]
    then
      timedatectl
      lsblk
      read -p "Select the media for make partitions: " media
      fdisk $media
      lsblk
      read -p "Select your boot partition: " boot
      read -p "Select your Linux partition: " linux
      mkfs.fat -F 32 $boot
      mkfs.ext4 $linux
      echo 'Format done'
      lsblk
      read -p "Press any key..." sahjad
      clear
      echo "Mounting the sistem"
      mount $linux /mnt
      mount --mkdir $boot /mnt/boot
      echo "Syestem mounted"
      reflector --country Spain --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
      echo "Mirrors selected"
      sleep 2
      pacstrap -K /mnt base linux linux-firmware linux-headers
      echo "Base sistem installed"
      sleep 2
      genfstab -U /mnt >> /mnt/etc/fstab
      echo "fstab created remeaber to check it"
      cp FastSetup.sh  /mnt/FastSetup.sh
      chmod +x /mnt/FastSetup.sh
      echo 'run the script another time'
      sleep 2
      arch-chroot /mnt
    else
      echo "You are in legacy mode, change to uefi into the firmwaresettings"
      echo "For now the script don't suports BIOS legacy. It's just for UEFI systems"
      read -p "Press any key..." jsbdsa
      echo "[ 1 ] Reboot"
      echo "[ 2 ] Shutdown"
      read -p "Choose an option: " err_firmMode
      if [ "$err_firmMode" -eq 1 ]
      then
        reboot
      elif [ "$err_firmMode" -eq 2 ]
      then
        shutdown now
      fi
    fi
  fi
fi
echo 'wellcome to arch-chroot'
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc
echo 'time succesfuly selected'
sleep 1
clear
echo LANG=es_ES.UTF-8 > /etc/locale.conf
locale-gen
sleep 3
echo KEYMAP=es > /etc/vconsole.conf
echo keyboard succesfully configured
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
systemctl enable NetworkManager
sleep 2
clear
echo "Please create a user"
useradd -m -s /bin/bash Admin
passwd Admin
echo "user created"
clear
usermod -aG wheel Admin
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel
echo "All done"
