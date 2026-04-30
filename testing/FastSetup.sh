#!/bib/bash
clear
echo "#########################################"
echo "############ ARCH FAST SETUP ############"
echo "#########################################"
echo ""
echo -e '\e[36m
                       -`
                      .o+`
                     `ooo/
                    `+oooo:
                   `+oooooo:
                   -+oooooo+:
                 `/:-:++oooo+:
                `/++++/+++++++:
               `/++++++++++++++:
              `/+++ooooooooooooo/`
             ./ooosssso++osssssso+`
            .oossssso-````/ossssss+`
           -osssssso.      :ssssssso.
          :osssssss/        osssso+++.
         /ossssssss/        +ssssooo/-
       `/ossssso+/:-        -:/+osssso+-
      `+sso+:-`                 `.-/+oso:
     `++:.                           `-/+/
     .`                                 `/
\e[0m'
echo ""
echo "Are you running in chroot?"
read -p "Type [y/n]" CR
if [ "$CR" = y ]
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
  else
    echo "You are in legacy mode, change to uefi into the firmware"
    echo "[ 1 ] Reboot"
    echo "[ 2 ] Shutdown"
    echo "[ 3 ] I will stay in the iso"
    read -p "Type one option: " mod
    if [ "$mod" -eq 1 ]
    then
    echo "Option 1"
      reboot
    elif [ "$mod" -eq 2 ]
    then
      shtdown now 
    elif [ "$mod" -eq 3 ]
    then
      exit 1
    fi
  fi
else  
  echo 'wellcome to arch-chroot'
  ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
  hwclock --systohc
  echo 'time succesfuly selected'
  sleep 1
  clear
  locale-gen
  echo LANG=es_ES.UTF-8 >> /etc/locale.conf
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
  pacman -Sy grub efibootmgr
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
  useradd -m -s /bin/bash Admin
  passwd Admin
  echo "user created"
  sleep 2s
  clear
  usermod -aG wheel Admin
  echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
  chmod 440 /etc/sudoers.d/wheel
  echo "All done"
  read -p "Press any key to continue..." nousedvar
fi