#!/bin/bash
# bootstrap.sh
set -e

# Install ansible using the PPA method
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible git

# Create ansible user with authorized key and passwordless sudo
if ! id -u ansible &>/dev/null; then
    sudo useradd -m -s /bin/bash ansible
    echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible
    sudo -u ansible mkdir -p /home/ansible/.ssh
    # TODO: The key is not yet available b/c we haven't cloned the repo
    sudo cp authorized_keys /home/ansible/.ssh/authorized_keys
    sudo chown ansible:ansible /home/ansible/.ssh/authorized_keys
    sudo chmod 700 /home/ansible/.ssh
    sudo chmod 600 /home/ansible/.ssh/authorized_keys
fi

# Clone roles repo (if not already present)
if [ ! -d "/usr/share/ansible/collections" ]; then
    sudo mkdir -p /usr/share/ansible/collections/ansible_collections
    sudo chown:chown ansible /usr/share/ansible -R
    sudo -u ansible git clone git@github.com:maxcole/ansible.git \
      /usr/share/ansible/collections/ansible_collections/rjayroach
fi

# Clone bootstrap repo to ansible user's home directory (if not already present)
if [ ! -d "/home/ansible/bootstrap" ]; then
    sudo -u ansible git clone https://github.com/maxcole/bootstrap.git /home/ansible/bootstrap
fi

# Run the bootstrap playbook
# sudo -u ansible ansible-playbook -i localhost, /home/ansible/bootstrap/configure.yml
