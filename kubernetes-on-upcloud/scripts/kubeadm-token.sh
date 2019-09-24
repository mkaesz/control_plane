#!/bin/bash

set -e

# Extract "host" argument from the input into HOST shell variable
eval "$(jq -r '@sh "USER=\(.user)"')"
eval "$(jq -r '@sh "PASSWORD=\(.password)"')"
eval "$(jq -r '@sh "HOST=\(.host)"')"


# Fetch the join command
#CMD=$(sshpass -p $PASSWORD "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
 #   $USER@$HOST kubeadm token create --print-join-command")


CMD=$(sshpass -p clearlinux ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null clearlinux@94.237.93.42 kubeadm token create --print-join-command)

# Produce a JSON object containing the join command
jq -n --arg command "$CMD" '{"command":$command}'
