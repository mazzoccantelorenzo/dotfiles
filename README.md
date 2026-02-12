# dotfiles

```zsh
git clone https://github.com/mazzoccantelorenzo/dotfiles.git ~/dotfiles
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
go install github.com/nametake/golangci-lint-langserver@latest
go install golang.org/x/tools/gopls@latest
ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -s ~/dotfiles/starship/starship.toml ~/.config/starship.toml
ln -s ~/dotfiles/ghostty/config ~/.config/ghostty/config

