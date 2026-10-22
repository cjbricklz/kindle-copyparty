#!/bin/sh
# Diagnostics for bring-up: everything goes to /mnt/us/copyparty/selftest.log
. /mnt/us/extensions/copyparty/bin/env.sh
OUT=$CP/selftest.log
{
  echo "== $(date)"; uname -a; echo "-- wlan0:"; ip -4 addr show wlan0 2>&1
  echo "-- mem:"; grep -E 'MemTotal|MemFree|MemAvailable' /proc/meminfo
  echo "-- /mnt/us:"; df -k /mnt/us; mount | grep ' /mnt/us '
  echo "-- python:"; ls -l "$PY"; "$PY" -V 2>&1
  echo "-- python modules:"; "$PY" -c 'import ssl,sqlite3,zlib,ctypes,socket,json;print("stdlib ok", ssl.OPENSSL_VERSION)' 2>&1
  echo "-- sfx:"; ls -l "$CP/copyparty-sfx.py"
  echo "-- iptables:"; iptables -S INPUT 2>&1 | head -20
} > "$OUT" 2>&1
say "selftest done -> copyparty/selftest.log"
