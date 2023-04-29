#!/usr/bin/env bash

# Install brew non-interactively using NONINTERACTIVE environment variable
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Nix via the recommended multi-user installation
yes | sh <(curl -L https://nixos.org/nix/install)

# Install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Remove existing home-manager directory if it exists
if [ -d "$HOME/.config/home-manager" ]; then
  rm -rf "$HOME/.config/home-manager"
fi

# Install Git using brew
brew install git

# Clone GitHub repo to ~/.config/home-manager
git clone https://github.com/8ta4/home-manager.git "$HOME/.config/home-manager"

# Uninstall Git using brew
brew uninstall git

# Change directory to cloned repo
cd "$HOME/.config/home-manager"

# Run home-manager switch and brew bundle
home-manager switch
brew bundle