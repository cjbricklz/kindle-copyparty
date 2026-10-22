# shared settings for the copyparty KUAL extension
CP=/mnt/us/copyparty
PY=/mnt/us/python3/usr/bin/python3.11
FBINK=/mnt/us/libkh/bin/fbink
LOG=$CP/copyparty.log
PIDFILE=$CP/copyparty.pid
PORT=3923

say() { [ -x "$FBINK" ] && "$FBINK" -q -y "${2:-5}" -x 1 "$1" 2>/dev/null; echo "$(date '+%F %T') $1" >> "$CP/ext.log"; }
get_ip() { ip -4 addr show wlan0 2>/dev/null | awk '/inet /{sub("/.*","",$2); print $2; exit}'; }
is_running() { [ -s "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; }
