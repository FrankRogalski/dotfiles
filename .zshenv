# .zshenv — sourced for EVERY zsh: interactive, non-interactive scripts, and
# `zsh some-script.sh` (which does NOT read .zshrc). Put here only what
# non-interactive shells also need. Interactive-only config (aliases, prompt,
# plugins, keybindings, functions) belongs in .zshrc.

. "$HOME/.cargo/env"

# Locale: used by git hooks and tools run non-interactively.
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Editor: the Helix binary is `hx` on macOS but `helix` on Linux. $EDITOR execs
# the raw binary, so an alias can't bridge the difference — pick it by OS.
if [[ "$(uname)" == "Darwin" ]]; then
  export EDITOR='hx'
  # Install/update gems into a user-owned dir instead of Homebrew's Ruby prefix,
  # so `gem update` never collides with `brew upgrade ruby`'s symlink step.
  # Lives here (not .zshrc) so the non-interactive update script sees it too.
  export GEM_HOME="$HOME/.gem"
else
  export EDITOR='helix'
fi
