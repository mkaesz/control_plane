#!/bin/sh

curl -o kvm-legacy.img.xz -O https://cdn.download.clearlinux.org/image/$(curl https://cdn.download.clearlinux.org/image/latest-images | grep '[0-9]'-kvm-legacy'\.')

unxz kvm-legacy.img.xz

dd if=kvm-legacy.img of=/dev/vdb bs=16M oflag=direct

