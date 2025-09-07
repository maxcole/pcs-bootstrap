# Bootstrap

This repository contains scripts to:

1. Setup existing hosts (RaspberryPi, MacOS, etc) to be managed by Ansible, and
2. Configure a host as an Ansible controller

## adopt.sh

### Overview

This script automates the setup of a Debian Linux vanilla system or derivative, e.g. Raspberry Pi, and a MacOS host to be remotely managed by Ansible. It:

- Installs the OS sudo package if not already installed
- Creates the user 'ansible' with passwordless sudo
- Pulls an authorized_keys file to ansible user's `$HOME/.ssh` directory with appropriate permissions

### Requirements

- The user running the script has sudo permissions or can su to root
- Internet connectivity
- An SSH key with access to specific GitHub repositories

### Usage

```bash
wget -qO- https://raw.githubusercontent.com/maxcole/pcs-bootstrap/refs/heads/main/adopt.sh | bash -s -- all
```

OR if running as a non root user with sudo privileges:

```bash
wget -qO- https://raw.githubusercontent.com/maxcole/pcs-bootstrap/refs/heads/main/adopt.sh | sudo bash -s -- all
```


## adopt_mac.sh

### Overview

Before a Mac can be managed be ansible it requires a package manager and a python interpreter. This script automates the installation process. It:

- Installs Homebrew which in turn installs Xcode
- Uses Homebrew to install python3 and wget
- Runs the `adopt.sh` script

### Requirements

- The same as `adopt.sh`

### Usage

```bash
curl -o https://raw.githubusercontent.com/maxcole/pcs-bootstrap/refs/heads/main/adopt_mac.sh | bash -s --
```


## controller.sh

### Overview

- Installs the Ansible package
- Clones the Ansible PCS collections: infra and user
- Ensures the collection ownership is the Ansible user

### Requirements

- Ansible user exists on the system (manually created with appropriate capabilities and access or from running bootstrap.sh)

### Usage

```bash
wget -qO- https://raw.githubusercontent.com/maxcole/pcs-bootstrap/refs/heads/main/controller.sh | bash -s -- all
```
