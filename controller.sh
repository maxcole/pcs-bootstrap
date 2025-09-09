#!/bin/bash
set -e

# Environment variables
USER=ansible
ANSIBLE_DIR="$HOME/.ansible"
COLLECTIONS_DIR="$ANSIBLE_DIR/collections/ansible_collections"
COLLECTIONS_URLS=("git@github.com:maxcole/pcs.infra.git" "git@github.com:maxcole/pcs.user.git")
REPO_URL="git@github.com:maxcole/pcs-bootstrap.git"
REPO_DIR=$HOME/pcs/bootstrap

debug() {
  echo "controller: $1"
}

# Parse Git URL to create destination directory
parse_git_url_to_dir() {
    local git_url=$1
    local repo_name

    # Extract repository name from git URL (e.g., "pcs.infra.git" from "git@github.com:maxcole/pcs.infra.git")
    repo_name=$(basename "$git_url" .git)

    # Split on dots and create directory structure (e.g., "pcs.infra" becomes "pcs/infra")
    echo "$repo_name" | sed 's/\./\//g'
}

install() {
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
        apt install -y ansible git nmap'
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
clone() {
  # Clone this repo
  git clone $REPO_URL $REPO_DIR

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
    ln -s $dest_path $HOME/pcs
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
  functions_to_call+=("install" "clone")
elif [ $# -gt 0 ]; then
  functions_to_call=("$@")
else
  echo "Usage: $0 [params]"
  echo "  all: Execute all of the below commands"
  echo ""
  echo "  install: Install ansible and related dependencies"
  echo "  clone: Clone the PCS repositories"
  echo ""
fi

for function_to_call in "${functions_to_call[@]}"; do
  $function_to_call
done
