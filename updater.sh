if [ $# -lt 2 ]; then
    echo "usage: $0 <name> <command...>"
    exit 1
fi

FILENAME="$1"
shift
INPUT="$*"
mkdir -p "$HOME/dotfiles/logs"
LOGFILE="$HOME/dotfiles/logs/$FILENAME-updater.log"
exec > >(tee "$LOGFILE") 2>&1

(eval "$INPUT")
STATUS=$?
#this can not be done sooner since the eval needs to work with unset variables sometimes
set -u
if [ $STATUS -eq 0 ]; then
    echo 'update finished'
    sleep 2
else
    echo "FAILED ($STATUS) — pane stays open"
    exec $SHELL
fi
