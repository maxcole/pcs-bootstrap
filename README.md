# Bootstrap

This repository contains the bootstrap script which initializes the PCS home lab infrastructure control node

## Overview

This script automates the initial configuration of a Debian Linux vanilla system or derivative, e.g. Raspberry Pi, to function as a PCS control node by doing the following:

- Installing Ansible
- Creating an Ansible user
- Installing the Ansible PCS collection

## Requirements

- sudo is already installed
- The user running the script has sudo permissions
- Internet connectivity
- An SSH key with access to specific GitHub repositories

## What it does

### Bootstrap Script (`bootstrap.sh`)

1. Installs the latest Ansible release
2. Creates a user `ansible` with an authorized_keys file and passwordless sudo
3. Clones the pcs.common Ansible collection repo and assigns ownership to the Ansible user

## Usage

```bash
curl -sSL https://raw.githubusercontent.com/maxcole/pcs-bootstrap/refs/heads/main/bootstrap.sh | bash -s -- -icu ansible
```

## Files

- `bootstrap.sh` - Main bootstrap script
