#!/bin/sh
. /mnt/us/extensions/copyparty/bin/env.sh
if is_running; then say "copyparty UP: http://$(get_ip):$PORT"; else say "copyparty is not running"; fi
