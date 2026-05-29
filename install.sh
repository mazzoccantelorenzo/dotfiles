#!/usr/bin/env bash

# --- Setup Directories ---
# Define the root of the dotfiles repository
DOTFILES=$HOME/dotfiles

# Ensure the config directory exists
mkdir -p "$HOME/.config"

# --- Atuin Setup ---
# Atuin: Shell history replacement
mkdir -p "$HOME/.config/atuin"
ln -sf "$DOTFILES/atuin/config.toml" "$HOME/.config/atuin/config.toml"

# --- Terminal & Editor Links ---
# Ghostty: Modern terminal emulator
ln -sf "$DOTFILES/ghostty" "$HOME/.config/ghostty"

# Helix: Post-modern modal text editor
ln -sf "$DOTFILES/helix" "$HOME/.config/helix"

# Neovim: Extensible Vim-based text editor
ln -sf "$DOTFILES/nvim" "$HOME/.config/nvim"

# Starship: Cross-shell customizable prompt
ln -sf "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"

# --- Shell Configuration ---
# Zsh: Primary interactive shell
ln -sf "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"

echo "Dotfiles installation complete!"
