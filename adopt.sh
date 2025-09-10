#!/usr/bin/env bash
set -e

# Environment variables
AUTHORIZED_KEYS_URL="https://github.com/rjayroach.keys"
USER="ansible"

# Download and source the script
if [ ! -f /tmp/pcs-library.sh ]; then
  wget -O /tmp/pcs-library.sh https://raw.githubusercontent.com/maxcole/pcs-bootstrap/refs/heads/main/library.sh
fi
source /tmp/pcs-library.sh

# Support functions
debug() {
  echo "adopt: $1"
}

# Detect the OS
# os() {
#   if [[ "$OSTYPE" == "linux-gnu"* ]]; then
#     echo "linux"
#   elif [[ "$OSTYPE" == "darwin"* ]]; then
#     echo "macos"
#   else
#     echo "unsupported"
#   fi
# }


# Get the user's home directory based on OS
userhome() {
  if [[ "$(os)" == "macos" ]]; then
    echo "/Users/$USER"
  else
    echo "/home/$USER"
  fi
}


# Configure dependencies
deps() {
  if [[ "$(os)" == "linux" ]]; then
    deps_linux
  elif [[ "$(os)" == "macos" ]]; then
    deps_macos
  fi
}

deps_linux() {
  if command -v sudo &> /dev/null && command -v curl &> /dev/null; then
    debug "Dependencies satisfied. Skipping"
    return
  fi

  apt update
  apt install curl sudo -y
  debug "Dependencies configured"
}

deps_macos() {
  ssh_status=$(sudo systemsetup -getremotelogin 2>/dev/null)
  if [[ "$ssh_status" == *"Off"* ]]; then
    debug "ERROR!!"
    debug ""
    debug "Open System Preferences and turn on Remote Login and enable Full Disk Access"
    debug "See: https://support.apple.com/lt-lt/guide/mac-help/mchlp1066/mac"
    exit 1
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    debug "ERROR!!"
    debug ""
    debug "python interpreter not found. Run 'xcode-select --install' from a terminal then rerun this script"
    exit 1
  fi

  debug "Dependencies satisfied. Skipping"
}


# Create user
user() {
  if id -u "$USER" &>/dev/null; then
    debug "User '$USER' already exists. Skipping"
    return 0
  fi

  if [[ "$(os)" == "linux" ]]; then
    create_user_linux
  elif [[ "$(os)" == "macos" ]]; then
    create_user_macos
  fi
  debug "Created user '$USER'"
}

create_user_linux() {
  useradd -m -s /bin/bash "$USER"
}

create_user_macos() {
    # Find the next available UID (starting from 501 for regular users)
    local next_uid=501
    while id -u "$next_uid" &>/dev/null; do
        ((next_uid++))
    done

    # Create the user with all attributes using here document
    dscl . << EOF
-create "$(userhome)" UserShell /bin/zsh
-create "$(userhome)" RealName "$USER"
-create "$(userhome)" UniqueID $next_uid
-create "$(userhome)" PrimaryGroupID 20
-create "$(userhome)" NFSHomeDirectory "$(userhome)"
EOF

    # Create home directory
    createhomedir -c -u "$USER"
}


# Enable passwordless sudo for user
sudox() {
  if [[ "$(os)" == "linux" ]]; then
    if [ -f "/etc/sudoers.d/$USER" ]; then
      debug "/etc/sudoers.d/$USER already exists. Skipping"
      return
    fi
    echo "$USER ALL=(ALL) NOPASSWD:ALL" | tee "/etc/sudoers.d/$USER" > /dev/null

  elif [[ "$(os)" == "macos" ]]; then
    # Add user to admin group for sudo access
    dscl . -append /Groups/admin GroupMembership $USER
    echo "$USER ALL=(ALL) NOPASSWD:ALL" | tee "/private/etc/sudoers.d/$USER" > /dev/null
  fi
  debug "Setup sudo for user '$USER'"
}


# Setup SSH keys for user
ssh_keys() {
  local home_dir
  home_dir=$(userhome)

  # Create .ssh directory
  mkdir -p "$home_dir/.ssh"

  if [ -f "$home_dir/.ssh/authorized_keys" ]; then
    debug "$home_dir/.ssh/authorized_keys already exists. Skipping"
    return
  fi

  # Download and setup authorized keys
  curl -o "$home_dir/.ssh/authorized_keys" "$AUTHORIZED_KEYS_URL"

  # Set proper ownership and permissions
  chown -R "$USER:$(id -gn "$USER" 2>/dev/null || echo "staff")" "$home_dir/.ssh"
  chmod 700 "$home_dir/.ssh"
  chmod 600 "$home_dir/.ssh/authorized_keys"
  debug "Setup SSH keys for user '$USER' from $AUTHORIZED_KEYS_URL"
}


# Check if running as root
if [[ $EUID -ne 0 ]]; then
  debug "This script must be run as root (or use sudo)"
  exit 1
fi

# Check OS support before proceeding
if [[ "$(os)" == "unsupported" ]]; then
  debug "Unsupported operating system: $OSTYPE"
  exit 1
fi


# Parse command line arguments
functions_to_call=()

if [ $# -eq 1 -a "$1" = "all" ]; then
  functions_to_call+=("deps" "user" "sudox" "ssh_keys")
elif [ $# -gt 0 ]; then
  functions_to_call=("$@")
else
  echo "Usage: $0 [params]"
  echo "  all: Execute all of the below commands"
  echo ""
  echo "  deps: Configure required dependencies"
  echo "  user: Create the user '$USER'"
  echo "  sudox: Create passwordless sudo for the user '$USER'"
  echo "  ssh_keys: Add the authorized_keys file for the user '$USER'"
  echo ""
fi

for function_to_call in "${functions_to_call[@]}"; do
  $function_to_call
done
