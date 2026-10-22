#!/bin/sh
. /mnt/us/extensions/copyparty/bin/env.sh
if is_running; then kill "$(cat "$PIDFILE")"; sleep 1; kill -9 "$(cat "$PIDFILE")" 2>/dev/null; fi
rm -f "$PIDFILE"
iptables -D INPUT -p tcp --dport $PORT -j ACCEPT 2>/dev/null
iptables -D OUTPUT -p tcp --sport $PORT -j ACCEPT 2>/dev/null
lipc-set-prop com.lab126.powerd preventScreenSaver 0 2>/dev/null
say "copyparty stopped"
