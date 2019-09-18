#!/bin/sh

curl -o kvm-legacy.img.xz -O https://cdn.download.clearlinux.org/image/$(curl https://cdn.download.clearlinux.org/image/latest-images | grep '[0-9]'-kvm-legacy'\.')

unxz kvm-legacy.img.xz

dd if=kvm-legacy.img of=/dev/vdb bs=16M oflag=direct

mkdir /mnt
mount /dev/vdb1 /mnt
#chroot /mnt
#useradd mkaesz
#mkdir -p /home/mkaesz/.ssh

#echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEArVZFm7vRuQehYf8Qcx0MhgEWaSiRliee+Rr6YoMESoqOZ3K5+7b94Bs/aMbZeXeHJ1oH0VrLPUk1ZUMr9KufZoqDn3PPmuIUiPvbvBNYABHjkmf44W9WARGJypdYMkSp/1URZ+T8UDtWgGMYt1pmK/rackPBXLgXDNgfDRYuNc+XD19k3UdZ2OSV+l/a29snN4aDi5C+CA/bqys+Zela/CHJcB3BxhQWqZySLbOoMzh1aeFQ49Hj7tHbrxmMgP5p4P8ybN3m/tlzAHB9VhMtS75W0T9dYVdKcBMyS/0gdbFghMvfxpaN6/MW+3zkSS2xZ4KaGgpN8cJEN4X5Ft9FRw==" > /home/mkaesz/.ssh/authorized_keys

curl systymd file
curl prepare custom image shell sctipt

cp auf vdb
cp auf vdb

systemctl enable service

umount /mnt
