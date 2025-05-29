#!/usr/bin/bash
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Manjaro-Grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
