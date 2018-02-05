echo "===== Confirguration under chroot ====="

echo 
echo ">> Enter root password"
passwd 


echo 
echo ">> Set time zone"
ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
hwclock --systohc --utc

echo 
echo ">> Set locale"
for locale_name in 'zh_TW.UTF-8 UTF-8' 'zh_TW BIG5' 'en_US.UTF-8 UTF-8' 'en_US ISO-8859-1'; do
    sed -i 's/^# *\($locale_name\)/\1/' /etc/locale.gen
done
locale-gen
mkinitcpio -p linux

echo 
echo ">> Baisc network setting"
pacman -S dnsmasq wget iw wpa_supplicant dialog networkmanager --noconfirm --needed
systemctl enable NetworkManager.service

echo ">> SSH"
pacman -S openssh --noconfirm --needed
systemctl enable sshd

echo 
echo "Create a sudo user"
echo -n ">> Enter the username: "
read username
useradd -m -g users -G wheel -s /bin/bash $username
passwd $username

echo 
echo  ">> Add the wheel group to sudoers"
pacman -S vim --noconfirm --needed
echo ">> Press Enter to edit group wheel by visudo"
read
visudo

echo 
echo ">> GRUB"
pacman -S grub efibootmgr --noconfirm --needed
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg
mkdir -p /boot/efi/EFI/BOOT
cp /boot/efi/EFI/grub/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
