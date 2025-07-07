#!/bin/bash
# bootstrap.sh
set -e

# Install ansible
sudo apt update
sudo apt install -y ansible git

# Create ansible user with authorized key and passwordless sudo
if ! id -u ansible &>/dev/null; then
    sudo useradd -m -s /bin/bash ansible
    echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible
    sudo -u ansible mkdir -p /home/ansible/.ssh
    sudo cp authorized_keys /home/ansible/.ssh/authorized_keys
    sudo chown ansible:ansible /home/ansible/.ssh/authorized_keys
    sudo chmod 700 /home/ansible/.ssh
    sudo chmod 600 /home/ansible/.ssh/authorized_keys
    sudo -u ansible mkdir -p /home/ansible/.config /home/ansible/.local/bin /home/ansible/.local/share /home/ansible/.local/state /home/ansible/.cache
fi

# Clone roles repo (if not already present)
if [ ! -d "/etc/ansible/roles" ]; then
    sudo -u ansible mkdir -p /etc/ansible
    sudo -u ansible git clone git@github.com:maxcole/ansible.git /etc/ansible/roles
fi

# Clone bootstrap repo to ansible user's home directory
sudo -u ansible git clone https://github.com/maxcole/bootstrap.git /home/ansible/bootstrap

# Run the bootstrap playbook
sudo -u ansible ansible-playbook /home/ansible/bootstrap/bootstrap.yml
