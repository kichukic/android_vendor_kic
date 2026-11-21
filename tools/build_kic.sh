#!/bin/bash
# KIC OS build. Usage: VARIANT=userdebug|user GMS=true|false DEVICE=haydn vendor/kic/tools/build_kic.sh
set -o pipefail
TOP="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$TOP"
DEVICE="${DEVICE:-haydn}"
VARIANT="${VARIANT:-userdebug}"
export WITH_GMS="${GMS:-true}"
export USE_RBE=false
export USE_CCACHE=1 CCACHE_EXEC="$(command -v ccache)" CCACHE_DIR="${CCACHE_DIR:-$HOME/.ccache}"
[ -n "$CCACHE_EXEC" ] && ccache -M 200G >/dev/null
LOG="$TOP/build_kic.log"; : > "$LOG"
source build/envsetup.sh
lunch "kic_${DEVICE}-cp2a-${VARIANT}" >> "$LOG" 2>&1 || { echo BUILD_RESULT=LUNCH_FAILED | tee -a "$LOG"; exit 1; }
echo "TARGET_PRODUCT=$TARGET_PRODUCT LINEAGE_BUILD=$LINEAGE_BUILD WITH_GMS=$WITH_GMS" | tee -a "$LOG"
m bacon -j"$(nproc --all)" 2>&1 | tee -a "$LOG"
rc=${PIPESTATUS[0]}
echo "BUILD_RESULT=$rc" | tee -a "$LOG"
exit "$rc"
