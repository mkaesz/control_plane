#!/bin/sh

mkdir -p $1/etc/sudoers.d
echo "clearlinux ALL=(ALL) NOPASSWD:ALL" > $1/etc/sudoers.d/clearlinux

echo "export TERM=xterm" >> $1/home/clearlinux/.profile

exit 0
