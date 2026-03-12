#!/usr/bin/env bash

DOTFILES=$HOME/dotfiles

ln -sf $DOTFILES/ghostty $HOME/.config/ghostty
ln -sf $DOTFILES/helix $HOME/.config/helix
ln -sf $DOTFILES/nvim $HOME/.config/nvim
ln -sf $DOTFILES/starship $HOME/.config/starship
ln -sf $DOTFILES/zsh/.zshrc $HOME/.zshrc
