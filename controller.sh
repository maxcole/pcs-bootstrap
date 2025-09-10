#!/bin/bash
set -e

# Environment variables
USER=ansible
ANSIBLE_DIR="$HOME/.ansible"
COLLECTIONS_DIR="$ANSIBLE_DIR/collections/ansible_collections"
COLLECTIONS_URLS=("git@github.com:maxcole/pcs.infra.git" "git@github.com:maxcole/pcs.user.git")
REPO_URL="git@github.com:maxcole/pcs-bootstrap.git"
REPO_DIR=$HOME/pcs/bootstrap

# Download and source the script
if [ ! -f /tmp/pcs-library.sh ]; then
  wget -O /tmp/pcs-library.sh https://raw.githubusercontent.com/maxcole/pcs-bootstrap/refs/heads/main/library.sh
fi
source /tmp/pcs-library.sh

debug() {
  echo "controller: $1"
}

linux() {
  if [ -f /etc/os-release ]; then
    source /etc/os-release
    echo $ID
  elif [ -f /etc/redhat-release ]; then
    echo "rhel"
  else
    echo "unknown"
  fi
}


deps() {
  case $(linux) in
    ubuntu|debian)
      sudo apt install git nmap -y
      mise_linux
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
}

# Clone collections repositories
install() {
  # Clone this repo
  if [ ! -d "$REPO_DIR" ]; then
    git clone $REPO_URL $REPO_DIR
  fi

  for git_url in "${COLLECTIONS_URLS[@]}"; do
    # Parse the git URL to determine destination directory
    dest_subdir=$(parse_git_url_to_dir "$git_url")
    dest_path="$COLLECTIONS_DIR/$dest_subdir"

    # Check if destination already exists
    if [ -d "$dest_path" ]; then
      debug "Repository already exists at $dest_path. Skipping"
    else
      debug "Cloning repository $git_url to $dest_path"
      git clone --quiet $git_url $dest_path
    fi

    # Create softlink to repo dir
    ln -s $dest_path $HOME/pcs 2>/dev/null
  done
}


# Script must be run as the ansible user
if [[ "$(whoami)" != "$USER" ]]; then
  debug "Only run as user '$USER'. Abort"
  exit 1
fi

# Parse command line arguments
functions_to_call=()

if [ $# -eq 1 -a "$1" = "all" ]; then
  functions_to_call+=("deps" "install")
elif [ $# -gt 0 ]; then
  functions_to_call=("$@")
else
  echo "Usage: $0 [params]"
  echo "  all: Execute all of the below commands"
  echo ""
  echo "  deps: Install ansible and related dependencies"
  echo "  install: Clone the PCS repositories"
  echo ""
fi

for function_to_call in "${functions_to_call[@]}"; do
  $function_to_call
done
