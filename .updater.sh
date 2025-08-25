eval "$*"
local s=$?
(( s == 0 )) && exit
echo "FAILED ($s) — pane stays open"
exec $SHELL
