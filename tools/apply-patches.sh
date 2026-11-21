#!/bin/bash
# Apply KIC OS changes to LineageOS repositories. Safe to run more than once.
set -e
TOP="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$TOP"

apply() {
    local repo="$1" patch="$2"
    if git -C "$repo" apply --reverse --check "$patch" 2>/dev/null; then
        echo "already applied: $(basename "$patch")"
    else
        git -C "$repo" apply "$patch"
        echo "applied: $(basename "$patch")"
    fi
}

apply vendor/lineage "$TOP/vendor/kic/patches/vendor_lineage-0001-accept-kic-products.patch"
