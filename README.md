# Bootstrap

This repository contains bootstrap scripts which setup existing hosts (RaspberryPi, MacOS, etc) to be managed by Ansible and configures a host as an Ansible controller

## bootstrap.sh

### Overview

This script automates the initial configuration of a Debian Linux vanilla system or derivative, e.g. Raspberry Pi, to function as a PCS control node by doing the following:

- Installs the OS sudo package if not already installed
- Creates an Ansible user with passwordless sudo
- Pulls an authorized_keys file to Ansible's .ssh directory with appropriate permissions

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
