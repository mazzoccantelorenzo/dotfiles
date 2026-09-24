#!/usr/bin/env bash

# --- Setup Directories ---
# Define the root of the dotfiles repository
DOTFILES=$HOME/dotfiles

# Ensure the config directory exists
mkdir -p "$HOME/.config"

# Helper function to safely link files/directories
# Usage: safe_link <source> <target>
safe_link() {
    local src="$1"
    local dst="$2"
    
    # If the destination exists and is not a symlink, remove it (safely)
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "Removing existing directory/file: $dst"
        rm -rf "$dst"
    fi
    
    ln -sf "$src" "$dst"
}

# --- Install Dependencies ---

# 1. Install Oh My Zsh if it's missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed."
fi

# 2. Install Starship if it's missing
if ! command -v starship >/dev/null 2>&1; then
    echo "Installing Starship..."
    mkdir -p "$HOME/.local/bin"
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
else
    echo "Starship is already installed."
fi

# --- Atuin Setup ---
# Atuin: Shell history replacement
mkdir -p "$HOME/.config/atuin"
safe_link "$DOTFILES/atuin/config.toml" "$HOME/.config/atuin/config.toml"

# --- Terminal & Editor Links ---
# Ghostty: Modern terminal emulator
safe_link "$DOTFILES/ghostty" "$HOME/.config/ghostty"

# Helix: Post-modern modal text editor
safe_link "$DOTFILES/helix" "$HOME/.config/helix"

# Neovim: Extensible Vim-based text editor
safe_link "$DOTFILES/nvim" "$HOME/.config/nvim"

# Starship: Cross-shell customizable prompt
safe_link "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"

# --- Shell Configuration ---
# Zsh: Primary interactive shell
safe_link "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"

echo "Dotfiles installation complete!"
