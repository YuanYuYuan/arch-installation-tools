#!/bin/bash

echo ">> Start installation ... "
echo ">> Set ntp"
timedatectl set-ntp true

# echo
# echo -n ">> Enter the device (ex. /dev/sdx)to parted > "
# read device
device=/dev/sda
parted $device mklabel gpt
parted $device mkpart ESP fat32 1M 513M
parted $device set 1 boot on
parted $device mkpart primary ext4 513M 100%
parted $device print


echo 
echo ">> Format filesystem"
mkfs.fat ${device}1
mkfs.ext4 ${device}2

echo 
echo ">> Mount root and boot/efi"
mount ${device}2 /mnt
mkdir -p /mnt/boot/efi
mount ${device}1 /mnt/boot/efi

echo 
echo ">> Enter hostname"
read hostname
# hostname=arch-vm
echo $hostname > /mnt/etc/hostname

echo 
echo ">> Use the ranked mirrorlist"
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
curl https://raw.githubusercontent.com/YuanYuYuan/arch-installation-tools/master/taiwan-mirror-list.txt > ranked_mirrorlist
mv ranked_mirrorlist /etc/pacman.d/mirrorlist

echo 
echo ">> Install base packages"
pacstrap /mnt base base-devel

echo 
echo ">> Generate fstab"
genfstab -U /mnt >> /mnt/etc/fstab

curl https://raw.githubusercontent.com/YuanYuYuan/arch-installation-tools/master/chroot.sh > /mnt/chroot.sh
arch-chroot /mnt /bin/bash chroot.sh
rm /mnt/chroot.sh

echo 
echo "Unmount and poweroff"
umount -R /mnt
poweroff

