# Notes

## Target device analysis (2026-10-22)
- Kindle Paperwhite 4, firmware 5.18.1; USB shows as mass storage only (vendor 1949, Lab126), FAT, ~6.3 GB.
- Jailbreak tooling present: KUAL, MRInstaller, KindleForge, kterm, libkh (fbink), KOReader (with dropbear).
- Userland: ARMv7, VFPv3, hard-float (`/lib/ld-linux-armhf.so.3`) -> the `khf` Python build applies.
- No usbnet extension installed -> only WiFi can reach the device while it runs.
- /mnt/us is FAT: no symlinks, no exec bits needed (binaries run from it). The Python tree has zero symlinks.

## Decisions
- Python goes in `/mnt/us/python3` (the path its RPATH expects); no `/usr/bin` symlinks.
- Config requires login; a random password is generated per install, never committed.
- `hist:` points at `/mnt/us/copyparty/hist`; no indexing (`e2d` unset) and thumbnails off, for the weak CPU.
- No `PRTY_*`/other env guesses: only flags verified against `copyparty-sfx.py` 1.20.26 on a host.

## First on-device checklist (not yet done)
- [ ] KUAL menu appears
- [ ] Selftest: `python3.11 -V`, `import ssl,sqlite3,zlib,ctypes` all succeed
- [ ] First start (bytecode compile) completes; log in `copyparty/copyparty.log`
- [ ] Port 3923 reachable from LAN (iptables rule from start.sh; `iptables -C` may be unsupported on the Kindle's iptables)
- [ ] Upload/download works; WiFi survives screen-off

## Known risks
- sfx extracts to `$HOME/.cache` (HOME is set to `/mnt/us/copyparty`) - confirm it lands on FAT without issue.
- Memory: PW4 has ~512 MB RAM shared with the Kindle UI.
- Python zip digest is not pinned yet (`PY_ZIP_SHA256` in install.sh); pin after a trusted run.
