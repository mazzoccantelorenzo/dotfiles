# --- Path & Environment ---
# Standard Oh My Zsh path
export ZSH="$HOME/.oh-my-zsh"

# Extend PATH with Go binaries
export PATH=$PATH:$(go env GOPATH)/bin 

# --- Oh My Zsh Plugins ---
plugins=(
  git
  z
  sudo
  command-not-found
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# --- Tool Integrations ---
# Direnv: Environment variable management per directory
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

# Starship: Modern shell prompt
eval "$(starship init zsh)"

# Atuin: Better shell history
if [ -f "$HOME/.atuin/bin/env" ]; then
    . "$HOME/.atuin/bin/env"
    eval "$(atuin init zsh)"
fi

# --- Keybindings & Settings ---
# Set interrupt key to Ctrl-K
stty intr ^K

# --- Aliases ---
# Git: Cleanup local branches that are 'gone' on the remote
alias gdbr='git fetch --prune && git branch -vv | grep ": gone]" | awk "{print \$1}" | xargs git branch -D'

# iTerm2 Font Switcher: Interactive font picker using fzf
# Requires: fzf, iTerm2
change_font() {
    local font=$(fc-list :spacing=mono family | cut -d: -f2 | sort -u | fzf --prompt="Pick Font: ")
    if [[ -n "$font" ]]; then
        font=$(echo $font | sed 's/^[[:space:]]*//')
        echo -ne "\033]50;SetFont=$font\a"
        echo "Font set to: $font (current session only)"
    fi
}
alias cf='change_font'
