#!/bin/sh

mkdir -p /mnt
mount /dev/vdb1 /mnt

chroot /mnt /bin/bash -x <<'EOF'
# Password is clearlinux
useradd -d / -g users -p 'abuo1RBzXnOa.' -M -N clearlinux
mkdir -p /etc/sudoers.d
echo "clearlinux ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/clearlinux

echo "PermitRootLogin no" > /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
echo "ClientAliveInterval 30" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 5m" >> /etc/ssh/sshd_config

exit
EOF

umount /mnt
