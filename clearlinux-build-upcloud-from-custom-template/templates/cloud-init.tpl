#cloud-config
# Add users to the system. Users are added after groups are added.
users:
  - name: mkaesz
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users
    ssh_import_id: None
    lock_passwd: true
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEArVZFm7vRuQehYf8Qcx0MhgEWaSiRliee+Rr6YoMESoqOZ3K5+7b94Bs/aMbZeXeHJ1oH0VrLPUk1ZUMr9KufZoqDn3PPmuIUiPvbvBNYABHjkmf44W9WARGJypdYMkSp/1URZ+T8UDtWgGMYt1pmK/rackPBXLgXDNgfDRYuNc+XD19k3UdZ2OSV+l/a29snN4aDi5C+CA/bqys+Zela/CHJcB3BxhQWqZySLbOoMzh1aeFQ49Hj7tHbrxmMgP5p4P8ybN3m/tlzAHB9VhMtS75W0T9dYVdKcBMyS/0gdbFghMvfxpaN6/MW+3zkSS2xZ4KaGgpN8cJEN4X5Ft9FRw==
