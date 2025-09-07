#!/usr/bin/env bash

echo "Installing Homebrew"
bash -l -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Installing Python via Homebrew"
bash -l -c "brew install python wget"

echo "Running adopt.sh script. This will require your sudo password."
wget -qO- https://raw.githubusercontent.com/maxcole/pcs-bootstrap/refs/heads/main/adopt.sh | sudo bash -s -- all
