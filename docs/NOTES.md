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

## On-device results (2026-10-22)
- [x] KUAL menu appears
- [x] Selftest: Python 3.11.11, OpenSSL 1.1.1w, `ssl/sqlite3/zlib/ctypes/socket/json` import fine
- [x] First start OK (no bytecode-compile delay observed); copyparty 1.20.26 listening on 0.0.0.0:3923
- [x] Reachable from LAN over WiFi; copyparty confirmed working by the user
- Device facts: kernel 4.1.15-lab126 armv7l, ~500 MB RAM (~170 MB available), /mnt/us is `fuse.fsp`,
  stock iptables INPUT policy is DROP (start.sh inserts an ACCEPT for 3923; lost on reboot, re-added by Start).
- Pitfall seen: user typed `https://...:392` -> silent DROP -> timeout. Must be `http://` and port `3923`.
- Pitfall: USB connection unmounts /mnt/us from the Kindle, which breaks the running server.

## Remaining TODO
- [ ] `hist/` and `tmp/` live inside the served volume (copyparty warns `/copyparty/hist/4 gives access ...`);
      consider serving `/mnt/us/documents` + a dedicated uploads dir, or excluding `/copyparty`.
- [ ] Verify Stop menu entry cleans up (pid, iptables rule, preventScreenSaver) and that large uploads work.
- [ ] Measure WiFi/battery behaviour with screen off; consider a timed auto-stop.
- [ ] Optional: start-on-boot/upstart job (needs rootfs changes; deliberately not done).
- [ ] Optional: HTTPS (needs a cert; `cfssl` isn't available on-device, could generate on host and ship).
- [ ] Optional: `update.sh` to refresh copyparty/Python without recreating directories (install.sh refuses if present).
- [ ] Test on other Kindle models (soft-float devices need a different Python build).

## Known risks
- Memory: PW4 has ~512 MB RAM shared with the Kindle UI.
