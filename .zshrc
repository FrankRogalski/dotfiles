unsetopt PROMPT_SP
autoload -U colors && colors
if [[ $(uname) == "Darwin" ]]; then
  export PATH="$HOME/.local/bin:$HOME/.nimble/bin:/opt/homebrew/opt/perl/bin:$HOME/perl5/bin:/opt/homebrew/lib/ruby/gems/3.4.0/bin:/opt/homebrew/opt/ruby/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Users/frankrogalski/.rustup/toolchains/stable-aarch64-apple-darwin/bin:$PATH"
  export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
  export PERL5LIB="$HOME/perl5/lib/perl5:$PERL5LIB"
  export LIBRARY_PATH="$LIBRARY_PATH:/opt/local/lib/"
  export JAVA_HOME="/Users/frankrogalski/Library/Java/JavaVirtualMachines/sapmachine-17.0.11/Contents/Home"
  export DISABLE_AUTOUPDATER=1
  fpath+=('/opt/homebrew/share/zsh/site-functions')
  alias s=~/scripts/bash/shortcuts.nu
  alias bf=/Users/frankrogalski/privat/rust/BrainRust/target/release/brainfuck
  alias py=python3
  alias steplog='/Users/frankrogalski/Privat/python/steplog/main.py -p "`cat ~/steppass.txt`"'
  function update() {
    if [[ -o rm_star_silent ]]; then
      rm -f ~/dotfiles/logs/*
    else
      setopt rm_star_silent
      rm -f ~/dotfiles/logs/*
      unsetopt rm_star_silent
    fi
    zellij --layout "updates"
    for file in ~/dotfiles/logs/*(.N); do
      printf '%s==> %s <==%s\n' "$fg_bold[green]" "$file" "$reset_color"
      cat "$file"
    done
    echo "Update finished"
  }
  alias git-diff=~/scripts/bash/diff.nu
else
  alias update='sudo pacman -Syu && yay -Syu --answerclean All --answerdiff None && cargo install-update -a && rustup update stable && omz update'
  alias hx=helix
  alias py=~/.pyenv/versions/3.13.0/bin/python3
  alias haskell=ghc
  alias sudo='sudo '
  export PATH="$HOME/.cargo/bin:$HOME/.local/share/gem/ruby/3.2.0/bin:$HOME/programms/jdtls/bin:$HOME/.local/bin:$PATH"
  alias claude='(cd /home/frank/projects/claude-engineer && uv run ce3.py)'
fi

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.cargo/bin:$PATH"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

ZSH_THEME=""

zstyle ':omz:update' mode reminder

ZSH_DISABLE_COMPFIX=true

plugins=(git brew jira web-search zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.jenv/bin:$PATH"
jenv() {
  unfunction jenv
  eval "$(command jenv init -)"
  jenv "$@"
}

export MANPATH="/usr/local/man:$MANPATH"
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR='nvim'

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
fuck() {
  unfunction fuck
  eval $(command thefuck --alias)
  fuck "$@"
}
alias pip="py -m pip"
alias reload=". ~/.zshrc"
alias vim=nvim
alias vi=nvim
alias scroll=/Users/frankrogalski/Library/Developer/Xcode/DerivedData/DiscreteScroll-fuqmlrdyuvdzjphjjgbfmemfhvjs/build/Products/Debug/DiscreteScroll.app/Contents/MacOS/DiscreteScroll
alias wisdom="~/dotfiles/wisdom.nu"
alias ls=eza
alias neofetch="echo 'neofetch is dead, use fastfetch instead!' && fastfetch"
alias zbr="zig build run"
alias lg=lazygit
alias mv='mv -i'
alias hf=hyperfine
alias frick=fuck
alias uvsadd='uv add --script'
alias ipynb='uvx --with pandas --with openpyxl --with seaborn jupyter lab'

open_origin() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not in a git repo."
    return 1
  fi

  local url
  url=$(git remote get-url origin 2>/dev/null) || {
    echo "No origin remote."
    return 1
  }

  if [[ "$url" == git@*:* ]]; then
    url=${url/git@/https:\/\/}
    url=${url/:/\//}
  fi
  url=${url%.git}

  local opener
  if command -v open >/dev/null 2>&1; then
    opener="open"
  elif command -v xdg-open >/dev/null 2>&1; then
    opener="xdg-open"
  else
    echo "No opener (open/xdg-open) found."
    return 1
  fi

  "$opener" "$url"
}
alias open-origin=open_origin

gif2mp4() {
  ffmpeg -i $1 -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" $2
}

datecalc() {
  py -c "from datetime import datetime as dt, timedelta as td; print($1)"
}

is_discrete_scroll_running() {
    pgrep -x "DiscreteScroll" >/dev/null
}

stop_discrete_scroll() {
  if is_discrete_scroll_running; then
    pkill -TERM -x "DiscreteScroll"
    echo "DiscreteScroll sent SIGTERM."
  else
    echo "DiscreteScroll is not running."
  fi
}

if [ -z "$INTELLIJ_ENVIRONMENT_READER" ]; then
  wisdom
fi

eval "$(zoxide init zsh)"

# fzf keybindings (Ctrl+T files, Alt+C cd)
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
source /opt/homebrew/opt/fzf/shell/completion.zsh

# atuin for history (Ctrl+R, up arrow)
eval "$(atuin init zsh)"

eval "$(starship init zsh)"

if [[ $(uname) == "Darwin" ]]; then
  [[ ! -r '/Users/frankrogalski/.opam/opam-init/init.zsh' ]] || source '/Users/frankrogalski/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
else
  . "$HOME/.local/bin/env"
fi

# syntax highlighting (must be at end of .zshrc)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
