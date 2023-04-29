#!/usr/bin/env bash
set -e

# Install brew non-interactively using NONINTERACTIVE environment variable
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to your PATH:
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install Nix via the recommended multi-user installation
yes | sh <(curl -L https://nixos.org/nix/install)

# Install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# % brew shell-init: error retrieving current directory: getcwd: cannot access parent directories: No such file or directory Error: The current working directory doesn't exist, cannot proceed.
# The error message  occurs when the shell is unable to retrieve the current directory because it cannot access parent directories. This can happen if the current working directory has been deleted or moved.
cd $HOME

# Remove existing home-manager directory if it exists
if [ -d "$HOME/.config/home-manager" ]; then
  rm -rf "$HOME/.config/home-manager"
fi

# Clone GitHub repo to ~/.config/home-manager
git clone https://github.com/8ta4/home-manager.git "$HOME/.config/home-manager"

# Change directory to cloned repo
cd "$HOME/.config/home-manager"

# Run home-manager switch and brew bundle
home-manager switch
brew bundle
