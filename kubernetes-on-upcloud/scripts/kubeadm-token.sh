#!/bin/bash

set -ex

# Extract "host" argument from the input into HOST shell variable
eval "$(jq -r '@sh "HOST=\(.host) USER=\(.user)"')"

# Fetch the join command
CMD=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$HOST kubeadm token create --print-join-command)


#sshpass -p clearlinux ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null clearlinux@$HOST kubeadm token create --print-join-command
#ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' clearlinux@$HOST 'kubeadm token create --print-join-command'

# Produce a JSON object containing the join command
jq -n --arg command "$CMD" '{"command":$command}'
