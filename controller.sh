#!/bin/bash
set -e

# Environment variables
ANSIBLE_DIR="$HOME/.ansible"
COLLECTIONS_DIR="$ANSIBLE_DIR/collections/ansible_collections"
COLLECTIONS_URLS=("git@github.com:maxcole/pcs.infra.git" "git@github.com:maxcole/pcs.user.git")

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
}

# Clone collections repositories
clone() {
  for git_url in "${COLLECTIONS_URLS[@]}"; do
    # debug "Processing repository: $git_url"

    # Parse the git URL to determine destination directory
    dest_subdir=$(parse_git_url_to_dir "$git_url")
    dest_path="$COLLECTIONS_DIR/$dest_subdir"
    # debug "Destination directory: $dest_path"

    # Check if destination already exists
    if [ -d "$dest_path" ]; then
      echo "Repository already exists at $dest_path, skipping clone"
      continue
    fi
    git clone $git_url $dest_path
  done
}


# Script must be run as the ansible user
if [[ "$(whoami)" != "ansible" ]]; then
  echo "Only run as user ansible. abort."
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
  echo "  install: Install ansible and git"
  echo "  clone: Clone the PCS repositories"
fi

for function_to_call in "${functions_to_call[@]}"; do
  $function_to_call
done
