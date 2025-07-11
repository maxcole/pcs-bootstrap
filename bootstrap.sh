#!/bin/bash
# bootstrap.sh
set -e

# Parse command line arguments
SKIP_APT=false
USER="ansible"

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--skip-apt)
            SKIP_APT=true
            shift
            ;;
        *)
            USER="$1"
            shift
            ;;
    esac
done

# Install ansible using the PPA method (skip if -s flag is set)
if [ "$SKIP_APT" = false ]; then
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible git curl
fi

# Create user with authorized key and passwordless sudo
if ! id -u $USER &>/dev/null; then
    sudo adduser --disabled-password --gecos "" $USER
    echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
    sudo -u $USER mkdir -p /home/$USER/.ssh
    sudo -u $USER curl -o /home/$USER/.ssh/authorized_keys \
      https://raw.githubusercontent.com/maxcole/rws-bootstrap/refs/heads/main/authorized_keys
    sudo chown $USER:$USER /home/$USER/.ssh/authorized_keys
    sudo chmod 700 /home/$USER/.ssh
    sudo chmod 600 /home/$USER/.ssh/authorized_keys
fi

# Clone roles repo (if not already present)
if [ ! -d "/usr/share/ansible/collections" ]; then
    sudo mkdir -p /usr/share/ansible/collections/ansible_collections/rjayroach
    sudo chown $USER:$USER /usr/share/ansible -R
    sudo -u $USER git clone git@github.com:maxcole/rjayroach.common.git \
      /usr/share/ansible/collections/ansible_collections/rjayroach/common
fi
