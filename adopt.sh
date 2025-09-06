#!/bin/bash
set -e

# Environment variables
AUTHORIZED_KEYS_URL="https://github.com/rjayroach.keys"
USER="ansible"

# Create user with authorized key and passwordless sudo
apt install curl sudo -y

if ! id -u $USER &>/dev/null; then
  sudo sh -c "set -e useradd -m -s /bin/bash $USER"
fi

sudo sh -c "set -e && \
  echo \"$USER ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/$USER
  mkdir -p /home/$USER/.ssh && \
  curl -o /home/$USER/.ssh/authorized_keys $AUTHORIZED_KEYS_URL && \
  chown -R $USER:$USER /home/$USER/.ssh && \
  chmod 700 /home/$USER/.ssh && \
  chmod 600 /home/$USER/.ssh/authorized_keys"
