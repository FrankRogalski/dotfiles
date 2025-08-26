eval "$*"
local s=$?
if (( s == 0 )); then
    echo 'update finished'
    sleep 2
else
    echo "FAILED ($s) — pane stays open"
    exec $SHELL
fi
