#!/usr/bin/env bash
# Host-side installer: puts Python 3.11 + copyparty + a KUAL menu on a jailbroken Kindle.
# usage: ./install.sh /path/to/mounted/Kindle      (the USB-mass-storage mount, i.e. /mnt/us)
set -euo pipefail

K="${1:?usage: $0 /path/to/mounted/Kindle}"
HERE="$(cd "$(dirname "$0")" && pwd)"
B="$HERE/build"

PY_URL='https://www.mobileread.com/forums/attachment.php?attachmentid=215107'   # python3.11-khf.zip (toadclones, 2025-04-18)
PY_ZIP_SHA256='748115e3f67e241fc32ba96a2214869207e70fad72f6ef1923a8f958bbf4f2fa'   # python3.11-khf.zip, verified working on PW4 fw 5.18.1
CP_API='https://api.github.com/repos/9001/copyparty/releases/latest'

[ -d "$K/extensions" ] && [ -f "$K/system/version.txt" ] || { echo "$K does not look like a Kindle root (needs extensions/ and system/version.txt)"; exit 1; }
for d in python3 copyparty extensions/copyparty; do
  [ -e "$K/$d" ] && { echo "$K/$d already exists; remove it first (or use ./update.sh ideas in README)"; exit 1; }
done
for c in curl python3 xz tar unzip; do command -v $c >/dev/null || { echo "missing tool: $c"; exit 1; }; done

mkdir -p "$B"

echo "== copyparty-sfx.py (verified against GitHub release digest)"
curl -fsSL -o "$B/copyparty-sfx.py" https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py
want=$(curl -fsSL "$CP_API" | python3 -I -c '
import json,sys
for a in json.load(sys.stdin)["assets"]:
    if a["name"]=="copyparty-sfx.py": print(a["digest"].split(":")[1])')
got=$(sha256sum "$B/copyparty-sfx.py" | cut -d" " -f1)
[ "$want" = "$got" ] || { echo "sfx digest mismatch ($want vs $got)"; exit 1; }

echo "== python3.11-khf (hard-float, firmware > 5.16.2.1.1)"
[ -f "$B/py.zip" ] || curl -fsSL -o "$B/py.zip" "$PY_URL"
sum=$(sha256sum "$B/py.zip" | cut -d" " -f1); echo "py.zip sha256: $sum"
[ -z "$PY_ZIP_SHA256" ] || [ "$sum" = "$PY_ZIP_SHA256" ] || { echo "python zip digest mismatch"; exit 1; }
rm -rf "$B/py" "$B/pyroot" "$B/pkg"; mkdir -p "$B/py" "$B/pyroot" "$B/pkg"
unzip -q "$B/py.zip" -d "$B/py"
python3 -I "$HERE/tools/extract_ota.py" "$B"/py/python3.11-khf/Update_python3.11_install_khf_*.bin "$B/payload.tgz"
tar -xzf "$B/payload.tgz" -C "$B/pkg"
xz -dc "$B/pkg/python3.tar.xz" | tar -x -C "$B/pyroot"

echo "== config"
PW=$(python3 -I -c 'import secrets;print(secrets.token_urlsafe(9))')
mkdir -p "$B/stage/copyparty/tmp"
sed "s/@PASSWORD@/$PW/" "$HERE/copyparty.conf.template" > "$B/stage/copyparty/copyparty.conf"
cp "$B/copyparty-sfx.py" "$B/stage/copyparty/"

echo "== copying to $K (slow: ~4600 small files over USB)"
cp -r "$B/pyroot/python3" "$K/python3"
cp -r "$B/stage/copyparty" "$K/copyparty"
cp -r "$HERE/extension/copyparty" "$K/extensions/copyparty"
sync

cat <<MSG

Done. Eject + unplug the Kindle, enable WiFi, then in KUAL:
  copyparty -> Selftest, then Start copyparty.
Login:  user 'kindle'   password '$PW'   (also in copyparty/copyparty.conf on the Kindle)
MSG
