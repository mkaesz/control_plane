#!/bin/sh

curl -o kvm-legacy.img.xz -O https://cdn.download.clearlinux.org/image/$(curl https://cdn.download.clearlinux.org/image/latest-images | grep '[0-9]'-kvm-legacy'\.')

unxz kvm-legacy.img.xz

dd if=kvm-legacy.img of=/dev/vdb bs=16M oflag=direct

mkdir /mnt
mount /dev/vdb1 /mnt

curl -O https://raw.githubusercontent.com/mkaesz/control_plane/master/clearlinux/systemd/template-preparation.service
mv template-preparation.service /mnt/lib/systemd/system

curl -O https://raw.githubusercontent.com/mkaesz/control_plane/master/clearlinux/scripts/prepare-custom-template.sh
chmod +x prepare-custom-template.sh
mv prepare-custom-template.sh /mnt/

chroot /mnt
systemctl enable template-preparation.service
exit

umount /mnt
