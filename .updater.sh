INPUT="$*"
FILENAME=$(echo "$INPUT" | sed -E 's/[^a-zA-Z]+//g')
LOGFILE=${LOGFILE:-"$HOME/$FILENAME-updater.log"}
exec > >(tee "$LOGFILE") 2>&1

eval "$INPUT"
s=$?
set -u
if [ $s -eq 0 ]; then
    echo 'update finished'
    sleep 2
else
    echo "FAILED ($s) — pane stays open"
    exec $SHELL
fi
