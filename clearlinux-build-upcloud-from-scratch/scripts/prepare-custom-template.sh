#!/bin/sh
swupd bundle-add clr-installer

curl -O https://raw.githubusercontent.com/mkaesz/control_plane/master/clearlinux/scripts/kvm-legacy.yaml

clr-installer -c kvm-legacy.yaml

dd if=kvm-legacy.img of=/dev/vdb bs=16M oflag=direct

