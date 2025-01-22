# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
if [[ $(uname) == "Darwin" ]]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/Users/frankrogalski/.rustup/toolchains/stable-aarch64-apple-darwin/bin:$(brew --prefix)/opt/llvm/bin:$PATH"
  export LIBRARY_PATH="$LIBRARY_PATH:/opt/local/lib/"
  export JAVA_HOME="/Users/frankrogalski/Library/Java/JavaVirtualMachines/sapmachine-17.0.11/Contents/Home"
  fpath+=('/opt/homebrew/share/zsh/site-functions')
  alias s=~/scripts/bash/shortcuts.nu
  alias bf=/Users/frankrogalski/privat/rust/BrainRust/target/release/brainfuck
  alias py=python3
  alias claude="py /Applications/claude-engineer/main.py"
  alias update_claude="(cd /Applications/claude-engineer && git pull)"
  alias update=~/scripts/bash/bubu/bubu.nu
else
  alias hx=helix
  alias py=~/.pyenv/versions/3.13.0/bin/python3
  alias haskell=ghc
  alias sudo='sudo '
  export PATH="$HOME/.cargo/bin:$HOME/.local/share/gem/ruby/3.2.0/bin:$HOME/programms/jdtls/bin:$HOME/.local/bin:$PATH"
fi
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.cargo/bin:$PATH"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git z brew emoji jira web-search zsh-autosuggestions tmux)
export ZSH_TMUX_AUTOSTART=true
source $ZSH/oh-my-zsh.sh

# User configuration
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
if [[ $(uname) == "Darwin" ]]; then
    eval "$(pyenv virtualenv-init -)"
fi

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

export MANPATH="/usr/local/man:$MANPATH"
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR='nvim'

# You may need to manually set your language environment
# export LANG=en_US.UTF-8


# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
eval $(thefuck --alias)
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

if [ -z "$INTELLIJ_ENVIRONMENT_READER" ]; then
  wisdom
  if [[ $(uname) == "Darwin" ]]; then
    update
  fi
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ $(uname) == "Darwin" ]]; then
  # BEGIN opam configuration
  # This is useful if you're using opam as it adds:
  #   - the correct directories to the PATH
  #   - auto-completion for the opam binary
  # This section can be safely removed at any time if needed.
  [[ ! -r '/Users/frankrogalski/.opam/opam-init/init.zsh' ]] || source '/Users/frankrogalski/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
  # END opam configuration
else
  . "$HOME/.local/bin/env"
fi
