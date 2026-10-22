#!/bin/sh
. /mnt/us/extensions/copyparty/bin/env.sh
mkdir -p "$CP/tmp" "$CP/hist"

if is_running; then say "copyparty already running: http://$(get_ip):$PORT"; exit 0; fi
IP=$(get_ip)
[ -z "$IP" ] && { say "copyparty: no wifi (wlan0 has no IP)"; exit 1; }
[ -x "$PY" ] || { say "copyparty: python missing at $PY"; exit 1; }

# open the port (rules are lost on reboot, so (re)add if absent)
iptables -C INPUT -p tcp --dport $PORT -j ACCEPT 2>/dev/null || iptables -A INPUT -p tcp --dport $PORT -j ACCEPT
iptables -C OUTPUT -p tcp --sport $PORT -j ACCEPT 2>/dev/null || iptables -A OUTPUT -p tcp --sport $PORT -j ACCEPT

# keep the device (and wifi) awake while serving
lipc-set-prop com.lab126.powerd preventScreenSaver 1 2>/dev/null

export HOME=$CP TMPDIR=$CP/tmp PYTHONIOENCODING=utf-8
cd "$CP"
nohup "$PY" "$CP/copyparty-sfx.py" -c "$CP/copyparty.conf" >> "$LOG" 2>&1 &
echo $! > "$PIDFILE"
say "copyparty starting: http://$IP:$PORT (user: kindle)"
