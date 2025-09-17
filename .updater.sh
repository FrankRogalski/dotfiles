set -u
INPUT="$*"
FILENAME=$(echo "$INPUT" | sed -E 's/[^a-zA-Z]+//g')
mkdir -p "$HOME/dotfiles/logs"
LOGFILE=${LOGFILE:-"$HOME/dotfiles/logs/$FILENAME-updater.log"}
exec > >(tee "$LOGFILE") 2>&1

eval "$INPUT"
STATUS=$?
if [ $STATUS -eq 0 ]; then
    echo 'update finished'
    sleep 2
else
    echo "FAILED ($s) — pane stays open"
    exec $SHELL
fi
