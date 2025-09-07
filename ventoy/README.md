# PaaS Provider Notes

## Boot Ventoy from Grub

If not able to select the boot media from BIOS then with the Ventoy USB disk inserted:

```bash
grub> ls
grub> ls (hd1,msdos2)/
grub> set root=(hd1,msdos2)
grub> chainloader /EFI/BOOT/arm64x_real.efi
grub> boot
```


## Create Ventoy USB Disk from a Docker container:

```bash
docker run -d -v /home/roberto/dev/genesis:/genesis -p 22:2222 --device=/dev/sda1 --privileged -it dev/t3 
```

Note: After creating the Ventoy disk, May need to manually format the ISO partition to exfat
