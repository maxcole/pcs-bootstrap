# Bootstrap

Bootstrap script for home lab infrastructure setup.

## Overview

This script automates the initial setup of a home lab bootstrap machine (e.g., Raspberry Pi) by installing Ansible, configuring users, and running deployment playbooks.

## Requirements

- sudo is already installed
- Internet connectivity
- SSH key access to GitHub repositories

## What it does

### Bootstrap Script (`bootstrap.sh`)

1. Installs the OS Ansible package
2. Creates the Ansible user with an authorized key and passwordless sudo
3. Clones the ansible roles repo and assigns ownership to the Ansible user
4. Runs the ansible playbook `bootstrap.yml` in this repo

### Bootstrap Playbook (`bootstrap.yml`)

1. Installs rbenv and latest ruby for the Ansible user
2. Installs the para script
3. Stows `~/bootstrap/para/config.yml` to `~/.config/para/config.yml`
4. Runs `para init`

## Usage

```bash
curl -sSL https://raw.githubusercontent.com/maxcole/bootstrap/refs/heads/main/bootstrap.sh | bash -s -- -s
```

## Files

- `bootstrap.sh` - Main bootstrap script
- `bootstrap.yml` - Ansible playbook for application setup
- `authorized_keys` - SSH keys for the ansible user
