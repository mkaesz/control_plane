#!/bin/sh
swupd bundle-add clr-installer

curl kvm yaml

clr-installer -c kvm-legacy.yaml

dd if=kvm-legacy.img of=/dev/vdb bs=16M oflag=direct

