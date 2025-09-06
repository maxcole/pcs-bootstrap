#!/bin/bash
set -e

# Environment variables
AUTHORIZED_KEYS_URL="https://github.com/rjayroach.keys"
USER="ansible"

# Function to detect OS
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  else
    echo "unsupported"
  fi
}


# Function to get user home directory based on OS
userhome() {
  if [[ "$(detect_os)" == "macos" ]]; then
    echo "/Users/$USER"
  else
    echo "/home/$USER"
  fi
}


# Function to install dependencies
install_deps() {
  if [[ "$(detect_os)" == "linux" ]]; then
    apt update
    apt install wget sudo -y
  fi
}


create_user_macos() {
    # Find the next available UID (starting from 501 for regular users)
    local next_uid=501
    while id -u "$next_uid" &>/dev/null; do
        ((next_uid++))
    done

    # Create the user with all attributes using here document
    dscl . << EOF
-create "$(userhome)" UserShell /bin/bash
-create "$(userhome)" RealName "$USER"
-create "$(userhome)" UniqueID $next_uid
-create "$(userhome)" PrimaryGroupID 20
-create "$(userhome)" NFSHomeDirectory "$(userhome)"
EOF

    # Create home directory
    createhomedir -c -u "$USER"
}


# Function to create user on Linux
create_user() {
  if id -u "$USER" &>/dev/null; then
    echo "User $USER already exists"
    return 0
  fi

  if [[ "$(detect_os)" == "linux" ]]; then
    useradd -m -s /bin/bash "$USER"
    echo "Created user: $USER"
  elif [[ "$(detect_os)" == "macos" ]]; then
    create_user_macos
  fi
}


setup_sudo() {
  if [[ "$(detect_os)" == "linux" ]]; then
    echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/$USER" > /dev/null

  elif [[ "$(detect_os)" == "macos" ]]; then
    # Add user to admin group for sudo access
    dseditgroup -o edit -a "$USER" -t user admin
    # Setup passwordless sudo
    echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/$USER" > /dev/null
  fi
}


# Function to setup SSH keys (works for both OS)
setup_ssh_keys() {
  local home_dir
  home_dir=$(userhome)

  # Create .ssh directory
  mkdir -p "$home_dir/.ssh"

  # Download and setup authorized keys
  wget -O "$home_dir/.ssh/authorized_keys" "$AUTHORIZED_KEYS_URL"

  # Set proper ownership and permissions
  chown -R "$USER:$(id -gn "$USER" 2>/dev/null || echo "staff")" "$home_dir/.ssh"
  chmod 700 "$home_dir/.ssh"
  chmod 600 "$home_dir/.ssh/authorized_keys"
  # echo "SSH keys setup completed for $USER"
}


# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (or use sudo)"
  exit 1
# Check OS support before proceeding
elif [[ "$(detect_os)" == "unsupported" ]]; then
  echo "Error: Unsupported operating system: $OSTYPE"
  exit 1
fi


# Parse command line arguments
functions_to_call=()

if [ $# -eq 1 -a "$1" = "all" ]; then
  functions_to_call+=("install_deps" "create_user" "setup_sudo" "setup_ssh_keys")
elif [ $# -gt 0 ]; then
  functions_to_call=("$@")
else
  echo "Usage: $0 [params]"
  echo "  install_deps: Install any required dependencies"
  echo "  create_user: Create the Ansible user"
  echo "  setup_sudo: Create passwordless sudo for the Ansible user"
  echo "  setup_ssh_keys: Add an authorized key for the Ansible user to connect with"
fi

for function_to_call in "${functions_to_call[@]}"; do
  $function_to_call
done
