# KIC OS 24.0 (Android 17) — System Initialization & Build Guide

> **Device:** Xiaomi Mi 11X Pro / Redmi K40 Pro / Mi 11i (`haydn` / `haydnin`)  
> **SoC Platform:** Qualcomm Snapdragon 888 5G (`sm8350`)  
> **Base Android Release:** Android 17 (CP2A.260605.016 / LineageOS 24.0 base)  
> **Developer & Maintainer:** Kishor Thykkattu ([@kichukic](https://github.com/kichukic))  
> **Primary Build Target:** `kic_haydn-cp2a-userdebug`  
> **Purpose of this Document:** Complete, self-contained blueprint for recreating, syncing, patching, and building KIC OS from scratch on any new server or cloud build node.

---

## 1. Architecture & Included Features

KIC OS 24.0 is a customized, production-grade Android 17 distribution for `haydn` that replaces stock LineageOS branding and bundles advanced enhancements:

1. **Dedicated "KIC Mods" Hub:**
   - Integrated into top-level Settings (`Settings` homepage and `Settings -> System -> KIC Mods`).
   - Every mod is 100% toggleable in real time.
2. **Google Photos Unlimited Original Quality Backup:**
   - Pixel XL (`marlin`) spoof profile in `frameworks/base`.
   - Real-time user toggle backed by system property `persist.sys.kic.gphotos_spoof` (default: `true`).
3. **Sony Reality Display Engine:**
   - Display engine with presets: `Off`, `X-Reality Engine`, `Vivid Mode`, and `Triluminos Display`.
   - Toggleable and switchable from Settings.
4. **Status Bar Customizations:**
   - Live Network Traffic Monitor (upload/download speed overlay).
   - Battery Style switcher: `Portrait Icon`, `Text Only`, or `Hidden`.
5. **Kernel & Rooting:**
   - KernelSU / BakaSU rooted kernel integrated out of the box.
   - Prebuilt BakaSU companion app installed in system.
6. **Multimedia & Camera:**
   - Dolby Atmos spatial audio subsystem (`hardware/dolby`).
   - Xiaomi MIUI/Leica Camera stack (`vendor/xiaomi/miuicamera-haydn`).
7. **Security & Play Integrity:**
   - TrickyStore / keybox attestation (`keybox.xml`, `pif.json` installed to `/product/etc/security/`).
   - Private releasekey signing (`vendor/kic-priv/keys/`).

---

## 2. Server & Environment Setup

### Recommended Host Specifications
- **OS:** Ubuntu 22.04 LTS or 24.04 LTS x86_64
- **CPU:** 16+ Cores (32+ vCPUs recommended)
- **RAM:** Minimum 32 GB (64 GB+ recommended)
- **Disk:** 300+ GB high-speed NVMe SSD (mounted e.g. at `/serverhive` or `/home`)

### Install Required Host Dependencies
```bash
sudo apt update && sudo apt install -y \
    bc bison build-essential ccache curl flex g++-multilib gcc-multilib git \
    git-lfs gnupg gperf imagemagick lib32readline-dev lib32z1-dev libelf-dev \
    liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 \
    libxml2-utils lzop maven openjdk-21-jdk pngcrush rsync schedtool squashfs-tools \
    tmux unzip xsltproc zip zlib1g-dev python3 python-is-python3
```

### Git & GitHub CLI Configuration
```bash
git config --global user.name "Kishor Thykkattu"
git config --global user.email "38286414+kichukic@users.noreply.github.com"
git config --global color.ui auto

# Authenticate with GitHub (required for private repos and release assets)
gh auth login
```

### Install `repo` Tool
```bash
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
export PATH="$HOME/bin:$PATH"
```

---

## 3. Repository Initialization & Manifest

### Step 1: Initialize Base LineageOS 24.0
```bash
mkdir -p ~/kicos-haydn && cd ~/kicos-haydn
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs
```

### Step 2: Inject KIC OS Local Manifest
Create `.repo/local_manifests/kic_haydn.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
    <remote name="gh" fetch="https://github.com" />

    <!-- KIC OS Core & Branding -->
    <project name="kichukic/android_vendor_kic" path="vendor/kic" remote="gh" revision="kic-24.0" />

    <!-- Core Framework Overrides -->
    <remove-project name="LineageOS/android_frameworks_base" />
    <project name="kichukic/android_frameworks_base-new" path="frameworks/base" remote="gh" revision="kic-24.0" />

    <remove-project name="LineageOS/android_packages_apps_Settings" />
    <project name="kichukic/android_packages_apps_Settings" path="packages/apps/Settings" remote="gh" revision="kic-24.0" />

    <remove-project name="LineageOS/android_lineage-sdk" />
    <project name="kichukic/android_lineage-sdk" path="lineage-sdk" remote="gh" revision="kic-24.0" />

    <remove-project name="LineageOS/android_packages_apps_LineageParts" />
    <project name="kichukic/android_packages_apps_LineageParts" path="packages/apps/LineageParts" remote="gh" revision="kic-24.0" />

    <remove-project name="LineageOS/android_vendor_lineage" />
    <project name="kichukic/android_vendor_lineage" path="vendor/lineage" remote="gh" revision="kic-24.0" />

    <!-- haydn Device Trees, Kernel & Hardware -->
    <project name="kichukic/device_xiaomi_haydn" path="device/xiaomi/haydn" remote="gh" revision="kic-24.0" />
    <project name="kichukic/android_device_xiaomi_sm8350-common" path="device/xiaomi/sm8350-common" remote="gh" revision="kic-24.0" />
    <project name="kichukic/android_kernel_xiaomi_sm8350" path="kernel/xiaomi/sm8350" remote="gh" revision="kic-24.0" />
    <project name="LineageOS/android_hardware_xiaomi" path="hardware/xiaomi" remote="gh" revision="lineage-24.0" />

    <!-- Proprietary Vendor Blobs -->
    <project name="TheMuppets/proprietary_vendor_xiaomi_haydn" path="vendor/xiaomi/haydn" remote="gh" revision="lineage-24.0" />
    <project name="TheMuppets/proprietary_vendor_xiaomi_sm8350-common" path="vendor/xiaomi/sm8350-common" remote="gh" revision="lineage-24.0" />

    <!-- Camera & Audio Enhancements -->
    <project name="kichukic/vendor_xiaomi_miuicamera-haydn" path="vendor/xiaomi/miuicamera-haydn" remote="gh" revision="17.0" />
    <project name="kichukic/hardware_dolby" path="hardware/dolby" remote="gh" revision="main" />
    <project name="kichukic/android_vendor_kic_gapps" path="vendor/kic/gapps" remote="gh" revision="main" />

    <!-- Penguin OS UI & Experience Mods -->
    <project name="kichukic/penguin_packages_apps_PenguinLaboratory" path="packages/apps/PenguinLaboratory" remote="gh" revision="celerity" />
    <project name="kichukic/penguin_packages_apps_PenguinSystemUI" path="packages/apps/PenguinSystemUI" remote="gh" revision="celerity" />
    <project name="kichukic/penguin_packages_apps_PenguinDex" path="packages/apps/PenguinDex" remote="gh" revision="celerity" />
    <project name="kichukic/packages_apps_LMOFreeform" path="packages/apps/LMOFreeform" remote="gh" revision="celerity" />
    <project name="kichukic/packages_apps_GameSpace" path="packages/apps/GameSpace" remote="gh" revision="celerity" />

    <!-- RisingOS Personalizations & VendorSupport (PIF, Keybox & Spoofing Suite) -->
    <project name="kichukic/android_packages_apps_Personalizations" path="packages/apps/Personalizations" remote="gh" revision="seventeen" />
    <project name="kichukic/android_packages_apps_VendorSupport" path="packages/apps/VendorSupport" remote="gh" revision="seventeen" />
</manifest>
```

### Step 3: Synchronize Sources
```bash
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

---

## 4. Custom Repositories Inventory

All customized source trees are hosted under the `kichukic` GitHub organization:

| Repository URL | Target Path | Active Branch | Description |
|---|---|---|---|
| `https://github.com/kichukic/android_vendor_kic.git` | `vendor/kic` | `kic-24.0` | KIC OS product config, overlays, bootanimation, security assets |
| `https://github.com/kichukic/android_frameworks_base-new.git` | `frameworks/base` | `kic-24.0` | Google Photos spoofing toggle, SystemUI battery styles, Reality engine service |
| `https://github.com/kichukic/android_packages_apps_Settings.git` | `packages/apps/Settings` | `kic-24.0` | Dedicated "KIC Mods" hub, Google Photos switch, Reality Engine UI |
| `https://github.com/kichukic/android_lineage-sdk.git` | `lineage-sdk` | `kic-24.0` | Rebranded system strings (LineageOS -> KIC OS) across all English locales |
| `https://github.com/kichukic/android_packages_apps_LineageParts.git` | `packages/apps/LineageParts` | `kic-24.0` | Status bar, traffic monitor, hardware buttons UI rebranded to KIC OS |
| `https://github.com/kichukic/android_vendor_lineage.git` | `vendor/lineage` | `kic-24.0` | `envsetup.sh` patched to accept `kic_` prefix, version strings set to KIC-OS |
| `https://github.com/kichukic/device_xiaomi_haydn.git` | `device/xiaomi/haydn` | `kic-24.0` | Device tree for haydn with BakaSU and audio fixes |
| `https://github.com/kichukic/device_xiaomi_sm8350-common.git` | `device/xiaomi/sm8350-common` | `kic-24.0` | Common board tree for SM8350 platform |
| `https://github.com/kichukic/android_kernel_xiaomi_sm8350.git` | `kernel/xiaomi/sm8350` | `kic-24.0` | Linux 5.4 kernel with KernelSU/BakaSU integration |
| `https://github.com/kichukic/hardware_dolby.git` | `hardware/dolby` | `main` | Dolby Atmos sound enhancement HAL |
| `https://github.com/kichukic/android_vendor_xiaomi_miuicamera-haydn.git` | `vendor/xiaomi/miuicamera-haydn` | `main` | MIUI/Leica camera proprietary blobs and framework |

---

## 5. Private Signing Keys (`vendor/kic-priv`)

The build signs all APKs, recovery, and OTA packages using custom release keys:
- The keys directory is located at `vendor/kic-priv/keys/`.
- Required keys:
  - `releasekey.pk8` / `releasekey.x509.pem`
  - `platform.pk8` / `platform.x509.pem`
  - `shared.pk8` / `shared.x509.pem`
  - `media.pk8` / `media.x509.pem`
  - `networkstack.pk8` / `networkstack.x509.pem`
  - `nfc.pk8` / `nfc.x509.pem`
  - `bluetooth.pk8` / `bluetooth.x509.pem`
  - `cyngn-priv-app.pk8` / `cyngn-priv-app.x509.pem`
  - `sdk_sandbox.pk8` / `sdk_sandbox.x509.pem`
  - `testkey.pk8` / `testkey.x509.pem`
  - `verifiedboot.pk8` / `verifiedboot.x509.pem`

### Restoring Keys
If keys were backed up locally (e.g. from `/home/hijack/kic_haydn/kic-priv/keys/`):
```bash
mkdir -p vendor/kic-priv/keys
cp -a /path/to/backup/kic-priv/keys/* vendor/kic-priv/keys/
```

### Generating New Keys (If starting completely fresh)
If private keys are ever lost:
```bash
mkdir -p vendor/kic-priv/keys
for key in releasekey platform shared media networkstack nfc bluetooth cyngn-priv-app sdk_sandbox testkey verifiedboot; do
    ./development/tools/make_key vendor/kic-priv/keys/$key "/CN=KIC OS haydn/OU=KIC/O=KIC/ST=Kerala/C=IN"
done
```

---

## 6. GApps Fetching

KIC OS includes Google Mobile Services (GMS) by default via `vendor/kic/config/common.mk`:
```bash
./vendor/kic/tools/fetch-gapps.sh
```
*(Requires GitHub CLI logged into an account with access to `kichukic/android_vendor_kic_gapps` release assets).*

---

## 7. Build Execution Workflow

### Always Build in `tmux`
Builds take time and must be protected against SSH disconnection.

```bash
# Start a detached tmux session
tmux new-session -d -s kic-build

# Send the build command into the session
tmux send-keys -t kic-build "cd ~/kicos-haydn && source build/envsetup.sh && lunch kic_haydn-cp2a-userdebug && m bacon -j\$(nproc --all) 2>&1 | tee out/kic_bacon.log" C-m

# To monitor live:
tmux attach -t kic-build
```

### Direct Script Runner (`run_build.sh`)
You can use the automated runner script:
```bash
cat << 'EOF' > run_build.sh
#!/usr/bin/env bash
cd "$(dirname "$0")"
rm -f out/KIC_BUILD_SUCCESS out/KIC_BUILD_FAILED
source build/envsetup.sh
lunch kic_haydn-cp2a-userdebug
echo "Starting KIC OS bacon build at $(date)..."
m bacon -j$(nproc --all) 2>&1 | tee out/kic_bacon.log
BUILD_STATUS=${PIPESTATUS[0]}
if [ ${BUILD_STATUS} -eq 0 ]; then
    echo "==== KIC OS BUILD COMPLETED SUCCESSFULLY at $(date) ===="
    touch out/KIC_BUILD_SUCCESS
else
    echo "==== KIC OS BUILD FAILED at $(date) with exit code ${BUILD_STATUS} ===="
    touch out/KIC_BUILD_FAILED
fi
EOF
chmod +x run_build.sh
tmux new-session -d -s kic-build "./run_build.sh"
```

---

## 8. Critical Patches & Known Pitfalls (Engineering Cheatsheet)

When developing or adapting future Android 17 / 24.0 revisions, beware of these specific build pitfalls:

### 1. `BatteryMeterView.java` Missing Import
- **Symptom:** `error: cannot find symbol variable View` during `SystemUI-core javac`.
- **Cause:** `BatteryMeterView.java` uses `View.GONE` and `View.VISIBLE` in `updateBatteryStyle()`, but `android.view.View` was not imported.
- **Fix:** In `frameworks/base/packages/SystemUI/src/com/android/systemui/battery/BatteryMeterView.java`, ensure `import android.view.View;` is present.

### 2. BakaSU Prebuilt Dexpreopt Check
- **Symptom:** Dexpreopt error complaining about `<uses-library>` tags (`androidx.window.extensions`) in `BakaSU.apk`.
- **Fix:** In `device/xiaomi/haydn/bakasu/Android.mk`:
  ```makefile
  LOCAL_ENFORCE_USES_LIBRARIES := false
  ```

### 3. KernelSU Vendored Git Submodule Error
- **Symptom:** `You should use $(REPO_NAME) as a git submodule instead of copying code directly`.
- **Fix:** In `kernel/xiaomi/sm8350/KernelSU/kernel/Kbuild`, replace the count evaluation with a fallback:
  ```makefile
  KSU_LOCAL_VERSION := $(if $(filter 1,$(LOCAL_GIT_EXISTS)),$(shell cd $(KSU_SRC); $(GIT_BIN) rev-list --count HEAD),4557)
  ```

### 4. Settings Resource ID Scoping
- **Symptom:** `error: resource string/... not found` during `aapt2` compile of `kic_mods_settings.xml`.
- **Cause:** Preferences in `packages/apps/Settings` must have string resources declared inside `Settings/res/values/kic_strings.xml`, not only in `LineageParts`.

---

## 9. Artifact Output & Flashing

Upon successful compilation, artifacts reside in `out/target/product/haydn/`:
- `lineage-24.0-*-UNOFFICIAL-haydn.zip` (~2.0 GB)
- `boot.img` (~192 MB)
- `vendor_boot.img` (~96 MB)
- `dtbo.img` (~24 MB)
- `vbmeta.img` (~64 KB)

### Flashing via Fastboot & OrangeFox Recovery
```bash
# 1. Flash partition images
fastboot flash boot boot.img
fastboot flash vendor_boot vendor_boot.img
fastboot flash dtbo dtbo.img
fastboot flash vbmeta vbmeta.img

# 2. Reboot into recovery
fastboot reboot recovery

# 3. Sideload the ROM zip
adb sideload lineage-24.0-*.zip
```
