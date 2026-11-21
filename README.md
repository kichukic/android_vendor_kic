# KIC OS

KIC OS is a fast, clean Android 17 ROM built on LineageOS 24.0.

`vendor/kic` holds everything that makes a build KIC OS: the product
configuration, version and branding, the GApps hook, speed defaults and the
build scripts. Device support comes from the regular LineageOS-style device
trees.

## Devices

| Device | Codename | Product |
| :--- | :--- | :--- |
| Xiaomi Mi 11X Pro / Redmi K40 Pro / Mi 11i | `haydn` / `haydnin` | `kic_haydn` |

## Building

```bash
# 1. LineageOS 24.0 source
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs --depth=1
mkdir -p .repo/local_manifests
curl -L https://raw.githubusercontent.com/kichukic/android_vendor_kic/kic-24.0/manifest/kic.xml \
    -o .repo/local_manifests/kic.xml
repo sync -c -j8 --force-sync --no-clone-bundle --no-tags

# 2. KIC OS patches on top of LineageOS
vendor/kic/tools/apply-patches.sh

# 3. GApps (private; skip and build with GMS=false for vanilla)
vendor/kic/tools/fetch-gapps.sh

# 4. Build (userdebug or user; GMS=true or false)
VARIANT=userdebug GMS=true vendor/kic/tools/build_kic.sh
```

The OTA zip lands in `out/target/product/<device>/`.

## Signing

Release keys are read from `vendor/kic-priv/keys` when present. That
directory is never part of this repository.

## Layout

- `config/common.mk`: properties, GApps, speed defaults and signing every KIC OS build carries
- `config/version.mk`: version and variant
- `products/`: one product makefile per device
- `overlay/`: KIC OS resource overlays
- `patches/`: changes KIC OS needs in LineageOS repositories
- `manifest/kic.xml`: local manifest with the device repositories
- `tools/`: build, patch and GApps scripts
