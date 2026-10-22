# kindle-copyparty

Run [copyparty](https://github.com/9001/copyparty) (a single-file Python file server) directly on a
jailbroken Kindle, with a KUAL menu to start/stop it. No third-party apps or servers.

> **Status: working on-device.** Verified on a Kindle Paperwhite 4 (PW4), firmware 5.18.1, copyparty 1.20.26, Python 3.11.11.
> Please open issues with `copyparty/selftest.log` and `copyparty/copyparty.log` attached.

## Requirements
- Jailbroken Kindle with KUAL, hard-float userland (firmware > 5.16.2.1.1; PW4 verified via `ld-linux-armhf`)
- ~200 MB free on user storage
- Linux host with `curl python3 xz tar unzip`

## Install
1. Connect the Kindle by USB so it mounts as mass storage.
2. `./install.sh /path/to/Kindle`
3. Eject, unplug, enable WiFi. In KUAL: **copyparty → Selftest**, then **Start copyparty**.
4. Browse to `http://<kindle-ip>:3923`, user `kindle`, password printed by the installer.
   Use plain **http** (no TLS cert is generated) and the full port **3923**; the Kindle firewall silently drops
   other ports, so a typo just hangs instead of being refused.

**Gotcha:** while the Kindle is plugged into a computer its storage is unmounted, so the server stops being
usable and the device may drop off WiFi. Unplug, then run *Start copyparty* again.

## How it works
Stock Kindle firmware has no Python. This uses the community
[`python3.11-khf`](https://www.mobileread.com/forums/showthread.php?p=4506164) build, but **bypasses its OTA
installer**: `tools/extract_ota.py` de-obfuscates the signed `.bin` container (nibble-swap + XOR 0x7a) and the
payload tarball is unpacked straight into `/mnt/us/python3`. The OTA installer would also write symlinks into
the read-only rootfs, which has been reported to fail on PW4; nothing outside `/mnt/us` is modified here.

On start, `extension/copyparty/bin/start.sh` opens the TCP port in iptables, sets `preventScreenSaver`
(so WiFi stays up) and runs `python3.11 copyparty-sfx.py -c copyparty.conf`.

## Security
The config serves **all of `/mnt/us` read/write** behind one generated password over plain HTTP.
Use only on trusted networks. Edit `copyparty/copyparty.conf` on the device to narrow the volume.

## Layout
| Path | Purpose |
|---|---|
| `install.sh` | host installer (downloads + verifies, extracts, copies) |
| `tools/extract_ota.py` | unwraps Kindle `.bin` OTA containers |
| `copyparty.conf.template` | config; `@PASSWORD@` filled in at install time |
| `extension/copyparty/` | KUAL extension (start/stop/status/selftest) |
| `docs/NOTES.md` | device analysis, decisions, open questions |

Licensed MIT (this repo only). copyparty is MIT; the Python build is third-party and is downloaded, not redistributed.
