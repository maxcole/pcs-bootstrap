

# Detect the CPU architecture
arch() {
  local arch=$(uname -m)

  if [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
    echo "arm64"
  else
    echo "amd64"
  fi
}

# Detect the OS
os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  else
    echo "unsupported"
  fi
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

setup_xdg() {
  mkdir -p $HOME/.cache $HOME/.config $HOME/.local $HOME/.local/share $HOME/.local/state $HOME/.local/bin
}

# mise; shared with pcs-bootstrap/controller.sh
mise_linux() {
  sudo install -dm 755 /etc/apt/keyrings
  wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=$(arch)] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
  sudo apt update

  sudo apt install cosign curl gpg mise -y
}
