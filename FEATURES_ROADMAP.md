# KIC OS — feature roadmap

KIC OS 1.0 is LineageOS 24.0 (Android 17) for haydn, plus the `vendor/kic`
product layer, the kichukic device/kernel trees, Leica camera, Dolby and
KernelSU/SUSFS. This file tracks features to pull from RisingOS and how risky
each port is, so they can be done deliberately rather than grafted blind.

## Ground rules
- Never break the booting baseline. Each feature lands as its own commit and
  its own build; if it doesn't apply cleanly in reasonable effort, skip it.
- No stolen-keybox attestation. See "Spoofing" below.

## Already inherited for free (via the kichukic device tree)
These are device-level and are already in KIC OS without any ROM work:
- Battery / governor tuning (the "battery sauce" schedutil rate limits).
- Window-blur disable and GPU render savings.
- In-kernel app freezer, quick doze.
- KernelSU-Next / BakaSU 1.5.5 + SUSFS, preinstalled manager.
- Leica MIUI camera, Motorola Dolby Atmos, HyperOS Gallery/editor.

## Spoofing / "mod center" — important
RisingOS's spoofing is two different things wired through one service
(`AxSpoofManager`):
1. **Device/props spoofing (PIF, Pixel props)** — changes what the device
   *reports* (fingerprint, model). Legitimate to ship. BUT in the RisingOS tree
   it is entangled with #2: `PlayIntegritySpoofService`, `PixelDeviceRepository`
   and `AxSpoofManager` all sit alongside `android.security.trickystore.*` and
   the `keystore2` attestation hooks, and the service drives both. Porting the
   clean half onto LineageOS means rewriting `AxSpoofManager` to drop the
   trickystore/keystore2 path and registering a new system service — deep,
   security-sensitive work. Do it attended, on its own branch, with boot tests.
2. **Keybox hardware-attestation spoofing (TrickyStore)** — forges hardware
   attestation with a leaked OEM keybox. **Not shipping in KIC OS.** It relies
   on a stolen private key, leaked keyboxes get revoked in waves, and it is not
   something to build into a distributed ROM.

**Recommended PIF for KIC today:** since KIC ships KernelSU, basic Play
Integrity is best delivered as a post-flash KSU/Zygisk module
(PlayIntegrityFix), which is the current community-standard, keeps the ROM
clean, and is trivially updatable when Google changes checks. Bake-in can come
later via the attended PixelPropsUtils port if wanted.

## UI features to port (attended — each needs SystemUI/Settings work)
Ordered roughly by value vs. effort. All live in RisingOS `frameworks/base`
(seventeen) + their SystemUI/Settings and usually need RisingOS SettingsLib
and resources ported alongside:
- Dynamic Island / status-bar chip system (large; many commits).
- Double-tap-to-sleep on launcher/lockscreen.
- QS: custom sliders, glass/tinted shade styles, QS header images.
- System-wide custom fonts.
- Lockscreen: Now Playing placement, media art.
- Lyrics on lockscreen/AOD.

## Branding / infra TODO
- KIC OTA updater: re-add an Updater overlay pointing at a `kichukic/KIC_OTA`
  repo (mirror of the Rising_OTA setup) + a per-device JSON. Currently the
  LineageOS Updater and the device's RisingOS updater overlay are both kept out
  of the build.
- Boot animation and wallpapers: KIC-branded assets (placeholders for now).
- Signing: KIC release keys live only on the build server in `vendor/kic-priv`.
