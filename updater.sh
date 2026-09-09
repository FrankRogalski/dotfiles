if [ $# -lt 2 ]; then
    echo "usage: $0 <name> <command...>"
    exit 1
fi

FILENAME="$1"
shift
INPUT="$*"
mkdir -p "$HOME/dotfiles/logs"
LOGFILE="$HOME/dotfiles/logs/$FILENAME-updater.log"

# A pipeline instead of `exec > >(tee ...)`: zsh does not wait for process
# substitutions at exit, so the pane could close and take tee down before the
# last lines reached the log. A pipeline is waited for as a whole, and the
# subshell keeps the command's `set -e` from leaking into this script.
{ eval "$INPUT"; } 2>&1 | tee "$LOGFILE"
STATUS=$pipestatus[1]
#this can not be done sooner since the eval needs to work with unset variables sometimes
set -u
if [ $STATUS -eq 0 ]; then
    echo 'update finished' | tee -a "$LOGFILE"
    UPDATER_COUNT=$(pgrep -cf 'updater\.sh' 2>/dev/null || echo 0)
    if [ "$UPDATER_COUNT" -gt 1 ]; then
        sleep 2
    fi
else
    echo "FAILED ($STATUS) — pane stays open" | tee -a "$LOGFILE"
    # This shell talks to the pane directly. It used to inherit the tee
    # redirection, so everything run in it (colours, editors, pagers) ended up
    # in the log and was replayed raw into the terminal by `update`.
    exec $SHELL
fi
