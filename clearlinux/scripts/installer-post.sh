#!/bin/bash

CHROOTPATH=$1

scripts/add-server-login-issue.sh ${CHROOTPATH}

systemctl start sshd
systemctl enable sshd


exit 0

