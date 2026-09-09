autoload -U colors && colors
if [[ $(uname) == "Darwin" ]]; then
  export PATH="$HOME/.local/bin:$HOME/.nimble/bin:/opt/homebrew/opt/perl/bin:$HOME/perl5/bin:$HOME/.gem/bin:/opt/homebrew/opt/ruby/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Users/frankrogalski/.rustup/toolchains/stable-aarch64-apple-darwin/bin:$HOME/go/bin:$PATH"
  export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
  export PERL5LIB="$HOME/perl5/lib/perl5:$PERL5LIB"
  export LIBRARY_PATH="$LIBRARY_PATH:/opt/local/lib/"
  export DISABLE_AUTOUPDATER=1
  export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"
  fpath+=('/opt/homebrew/share/zsh/site-functions')
  alias s=~/scripts/bash/shortcuts.nu
  alias bf=/Users/frankrogalski/privat/rust/BrainRust/target/release/brainfuck
  # Packages injected when a script brings no inline metadata of its own.
  py_default_with=(numpy requests)
  # uv only honours a PEP 723 header when the script *is* the run target, so
  # `uv run --with ... python script.py` silently ignores its dependencies.
  # Sniff the header and pick the right form. Pure zsh, no fork, and it stops
  # after the first 30 lines rather than reading the whole file.
  function _py_has_pep723() {
    local line
    local -i n=0
    while IFS= read -r line; do
      [[ $line == '# /// script'(|[[:space:]]*) ]] && return 0
      (( ++n >= 30 )) && return 1
    done <$1
    return 1
  }
  function py() {
    if [[ $1 == *.py && -r $1 ]] && _py_has_pep723 $1; then
      uv run --script "$@"
    else
      uv run ${py_default_with[@]/#/--with=} python "$@"
    fi
  }
  # ty can't read a PEP 723 header, so ty-wrapper hands it uv's env for the
  # script. Name the file here instead: the shell knows exactly what is being
  # opened, so the wrapper needn't guess it back out of ~/.zsh_history.
  function hx() {
    if [[ $1 == *.py && -r $1 ]] && _py_has_pep723 $1; then
      PEP723_SCRIPT=${1:A} command hx "$@"
    else
      command hx "$@"
    fi
  }
  alias steplog='/Users/frankrogalski/Privat/python/steplog/main.py -p "`cat ~/steppass.txt`"'
  alias copilot='copilot --yolo'
  function _delete_logs() {
    if [[ -o rm_star_silent ]]; then
      rm -f ~/dotfiles/logs/*(N)
    else
      setopt rm_star_silent
      rm -f ~/dotfiles/logs/*(N)
      unsetopt rm_star_silent
    fi
  }
  # Print a pane log with everything but colour (SGR) escapes removed, so a
  # replayed log can never switch terminal modes, move the cursor, or set the
  # title. Carriage-return progress bars collapse to their final state.
  function _print_log() {
    perl -pe '
      s/\r\n/\n/g; s/^.*\r//;                    # keep what survived a CR
      s/\e\][^\a\e]*(?:\a|\e\\)?//g;              # OSC: titles, hyperlinks
      s/\e[P^_].*?(?:\e\\|$)//g;                  # DCS/PM/APC strings
      s/\e\[[0-?]*[ -\/]*[@-ln-~]//g;             # CSI except SGR (...m)
      s/\e[()*+][ -\/]*[0-~]//g;                  # charset designations
      s/\e[^\[]//g;                               # other two-byte escapes
      s/[\x00-\x08\x0b-\x1a\x1c-\x1f\x7f]//g;   # stray control bytes
    ' -- "$1"
    printf '\e[0m'
  }
  function update() {
    local lockfile="${TMPDIR:-/tmp}/dotfiles_update.lock"
    zmodload zsh/system
    : >>"$lockfile"
    # the lock lives on the subshell's fd, so the kernel drops it however we exit
    (
      if ! zsystem flock -t 0 "$lockfile" 2>/dev/null; then
        echo "update is already running (pid $(<"$lockfile"))."
        exit 1
      fi
      local mypid=$sysparams[pid]
      (print -- $mypid) >|"$lockfile"

      _delete_logs
      zellij --layout "updates"
      # zellij leaves bracketed paste on when it exits, and a killed pane or
      # crash can also leave mouse/focus reporting on or the cursor hidden.
      # Put the terminal back before printing anything into it.
      printf '\e[?2004l\e[?1004l\e[?1003l\e[?1002l\e[?1000l\e[?1006l\e[?25h\e[0m'
      stty sane 2>/dev/null
      for file in ~/dotfiles/logs/*(.N); do
        printf '\n%s==> %s <==%s\n' "$fg_bold[green]" `basename "$file" '.log'` "$reset_color"
        _print_log "$file"
      done
      _delete_logs
      printf '\n%s==> %s <==%s\n' "$fg_bold[green]" "Update finished" "$reset_color"
    )
  }
  alias git-diff=~/scripts/bash/diff.nu
  alias whatsnew='~/privat/python/news/releases.py'
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
source ~/.zsh-defer/zsh-defer.plugin.zsh

source ~/dotfiles/session.sh
zmodload zsh/system
if [[ -o interactive ]]; then
  # Async without zle callbacks: poll non-blocking around prompts/commands.
  exec {_adt_pw_fd}< <(bw get password 'h4e 10er' </dev/null 2>/dev/null)

  _adt_pw_cleanup() {
    [[ -n "${_adt_pw_fd:-}" ]] && exec {_adt_pw_fd}<&-
    unset _adt_pw_fd
    add-zsh-hook -d precmd _adt_pw_poll
    add-zsh-hook -d preexec _adt_pw_preexec
    unfunction _adt_pw_cleanup _adt_pw_poll _adt_pw_preexec _adt_pw_try_read 2>/dev/null
  }

  _adt_pw_try_read() {
    local pw
    [[ -n "${_adt_pw_fd:-}" ]] || return 1
    # non-blocking read; returns immediately if not ready
    if sysread -i "$_adt_pw_fd" -t 0 pw 2>/dev/null && [[ -n "$pw" ]]; then
      export ADT_PASSWORD="${pw%$'\n'}"
      _adt_pw_cleanup
      return 0
    fi
    return 1
  }

  _adt_pw_poll() {
    _adt_pw_try_read || true
  }

  _adt_pw_preexec() {
    [[ -n "${ADT_PASSWORD:-}" ]] && return
    _adt_pw_try_read && return
    if [[ "$1" == adtfs* ]]; then
      local pw
      pw="$(bw get password 'h4e 10er' </dev/null 2>/dev/null)" || return
      [[ -n "$pw" ]] && export ADT_PASSWORD="${pw%$'\n'}"
      _adt_pw_cleanup
    fi
  }

  add-zsh-hook precmd _adt_pw_poll
  add-zsh-hook preexec _adt_pw_preexec
fi

export PATH="$HOME/.jenv/bin:$PATH"
zsh-defer eval "$(jenv init -)"

export MANPATH="/usr/local/man:$MANPATH"
# EDITOR + LANG/LANGUAGE/LC_ALL moved to ~/.zshenv (needed by non-interactive shells too)

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
zsh-defer eval $(thefuck --alias)
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

stop_discrete_scroll() {
  if pgrep -x "DiscreteScroll" >/dev/null; then
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
eval "$(atuin init zsh)"
eval "$(starship init zsh)"

# fzf keybindings (Ctrl+T files, Alt+C cd)
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
source /opt/homebrew/opt/fzf/shell/completion.zsh

if [[ $(uname) == "Darwin" ]]; then
  [[ ! -r '/Users/frankrogalski/.opam/opam-init/init.zsh' ]] || source '/Users/frankrogalski/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
else
  . "$HOME/.local/bin/env"
fi

# If the line isn't a known command, treat it as a zoxide query.
_zshrc_accept_line() {
  local buffer="$BUFFER"
  local -a words
  words=(${(z)buffer})
  local cmd="${words[1]}"
  if [[ -n "$cmd" && "$cmd" != -* ]]; then
    if ! whence -w -- "$cmd" >/dev/null 2>&1; then
      if (( ${#words} == 1 )); then
        local expanded="${~cmd}"
        if [[ -d "$expanded" ]]; then
          BUFFER="cd ${(q)cmd}"
          zle .accept-line
          return
        fi
      fi
      if [[ "$cmd" != */* && $(command -v zoxide) ]]; then
        local match
        match="$(zoxide query -l -- "${words[@]}" 2>/dev/null | head -n 1)"
        if [[ -n "$match" ]]; then
          BUFFER="cd ${(q)match}"
        fi
      fi
    fi
  fi
  zle .accept-line
}
zle -N accept-line _zshrc_accept_line

# Disable numeric directory stack aliases from OMZ (e.g., `2` -> `cd -2`).
unalias 0 1 2 3 4 5 6 7 8 9 2>/dev/null

setopt auto_cd

# syntax highlighting (must be at end of .zshrc)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

