#!/bin/sh

mkdir -p /mnt
mount /dev/vdb1 /mnt

chroot /mnt /bin/bash -x <<'EOF'
# Password is clearlinux
useradd -d / -g users -p 'abuo1RBzXnOa.' -M -N clearlinux
mkdir -p /etc/sudoers.d
echo "clearlinux ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/clearlinux
echo "root:x:0:0:root:/root:/bin/bash" >> /etc/passwd
exit
EOF

umount /mnt
