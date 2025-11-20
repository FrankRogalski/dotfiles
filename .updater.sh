INPUT="$*"
FILENAME=${INPUT//[^[:alpha:]]/}
mkdir -p "$HOME/dotfiles/logs"
LOGFILE=${LOGFILE:-"$HOME/dotfiles/logs/$FILENAME-updater.log"}
exec > >(tee "$LOGFILE") 2>&1

eval "$INPUT"
#this can not be done sooner since the eval needs to work with unset variables sometimes
set -u
STATUS=$?
if [ $STATUS -eq 0 ]; then
    echo 'update finished'
    sleep 2
else
    echo "FAILED ($s) — pane stays open"
    exec $SHELL
fi
