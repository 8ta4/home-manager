#!/usr/bin/env bash

set -e

# Need sudo access on macOS
# https://github.com/Homebrew/install/blob/fc8acb0828f89f8aa83162000db1b49de71fa5d8/install.sh#L228
# This will prompt you for the password once, and then subsequent sudo commands will not require a password as long as the authentication is cached.
sudo true

# Install brew non-interactively using NONINTERACTIVE environment variable
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to your PATH
eval "$(/opt/homebrew/bin/brew shellenv)"
 
# Clean up the old backup file
# https://github.com/NixOS/nix/blob/89d3cc5a47a448f624ea4c9b43eeee00dcc88a21/scripts/install-multi-user.sh#L36-L37
readonly PROFILE_TARGETS=("/etc/bashrc" "/etc/profile.d/nix.sh" "/etc/zshrc" "/etc/bash.bashrc" "/etc/zsh/zshrc")
readonly PROFILE_BACKUP_SUFFIX=".backup-before-nix"

for target in "${PROFILE_TARGETS[@]}"; do
  backup_target="${target}${PROFILE_BACKUP_SUFFIX}"
  if [ -e "${backup_target}" ]; then
    sudo mv "${backup_target}" "${target}"
  fi
done

# Install Nix via the recommended multi-user installation
yes | sh <(curl -L https://nixos.org/nix/install)

# Nix won't work in active shell sessions until you restart them
# https://stackoverflow.com/a/24696790
exec $SHELL << EOF
set -e

# https://github.com/NixOS/nix/blob/89d3cc5a47a448f624ea4c9b43eeee00dcc88a21/doc/manual/src/installation/uninstall.md?plain=1#L68C1-L72
# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix

# Install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# % brew shell-init: error retrieving current directory: getcwd: cannot access parent directories: No such file or directory Error: The current working directory doesn't exist, cannot proceed.
# The error message occurs when the shell is unable to retrieve the current directory because it cannot access parent directories. This can happen if the current working directory has been deleted or moved.
cd

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
EOF
