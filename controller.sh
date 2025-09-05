#!/bin/bash
set -e

# Environment variables
ANSIBLE_COLLECTIONS_DIR="/usr/share/ansible/collections"
OUR_COLLECTIONS_DIR="$ANSIBLE_COLLECTIONS_DIR/ansible_collections/pcs"
GIT_CLONE_URL="git@github.com:maxcole/pcs.user.git"
GIT_CLONE_DESTINATION="$OUR_COLLECTIONS_DIR/user"

# Parse command line arguments
DO_INSTALL=true
DO_CLONE=true
USER=ansible

while getopts "ick:u::h" opt; do
    case $opt in
        c)
            DO_CLONE=true
            ;;
        i)
            DO_INSTALL=true
            ;;
        h)
            echo "Usage: $0 [-i] [-c]]"
            echo "  -c: Clone the ansible collections repository"
            echo "  -i: Install required packages"
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            echo "Use -h for help"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

# Install required packages (only if -i flag is set)
if [ "$DO_INSTALL" = true ]; then
  # Detect OS
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
  elif [ -f /etc/redhat-release ]; then
    OS="rhel"
  else
    OS="unknown"
  fi

  case $OS in
    ubuntu|debian)
      sudo sh -c 'set -e && \
        apt update && \
        # apt install -y software-properties-common && \
        # add-apt-repository --yes --update ppa:ansible/ansible && \
        apt install -y ansible git'
      ;;
    rhel|centos|fedora|rocky|almalinux)
      echo "Red Hat/CentOS/Fedora is not currently supported"
      exit 1
      ;;
    *)
      echo "Unknown OS is not currently supported"
      exit 1
      ;;
  esac
fi

# Clone collections repo (only if -c flag is set and not already present)
if [ "$DO_CLONE" = true ]; then
  if [ -d "$OUR_COLLECTIONS_DIR" ]; then
    # Directory exists, ensure proper ownership before proceeding
    sudo chown -R $USER:$USER $ANSIBLE_COLLECTIONS_DIR
  fi
  # Directory doesn't exist, create and clone
  sudo SSH_AUTH_SOCK="$SSH_AUTH_SOCK" sh -c "set -e && \
    mkdir -p $OUR_COLLECTIONS_DIR && \
    git clone $GIT_CLONE_URL $GIT_CLONE_DESTINATION && \
    chown -R $USER:$USER $ANSIBLE_COLLECTIONS_DIR"
fi
