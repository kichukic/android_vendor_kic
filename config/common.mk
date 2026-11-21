#
# KIC OS: shared product configuration
#

WITH_GMS ?= true
include vendor/kic/config/version.mk

# Identity
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.kic.version=$(KIC_VERSION) \
    ro.kic.variant=$(KIC_VARIANT) \
    ro.kic.display.version=$(KIC_DISPLAY_VERSION) \
    ro.kic.build.date=$(KIC_BUILD_DATE) \
    ro.kic.releasetype=UNOFFICIAL \
    ro.kic.maintainer=KIC

# Google apps
ifeq ($(WITH_GMS),true)
ifeq ($(wildcard vendor/kic/gapps/gapps.mk),)
$(error KIC OS GApps are missing: run vendor/kic/tools/fetch-gapps.sh, or build with GMS=false)
endif
$(call inherit-product, vendor/kic/gapps/gapps.mk)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.setupwizard.mode=OPTIONAL \
    ro.setupwizard.rotation_locked=true \
    ro.opa.eligible_device=true \
    ro.com.google.gmsversion=17
endif

# KIC OS overlay. It also keeps the LineageOS Updater and the device tree
# updater overlay (RisingOS OTA server) out of the build: KIC OS has no OTA
# server yet.
PRODUCT_PACKAGES += \
    KicFrameworksOverlay

# Speed: compile the always-running UI ahead of time instead of from profiles
PRODUCT_DEXPREOPT_SPEED_APPS += \
    SystemUI \
    TrebuchetQuickStep \
    Settings
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile
PRODUCT_ALWAYS_PREOPT_EXTRACTED_APK := true

# Signing: KIC OS release keys, kept only on the build server
ifneq ($(wildcard vendor/kic-priv/keys/releasekey.x509.pem),)
PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/kic-priv/keys/releasekey
PRODUCT_EXTRA_RECOVERY_KEYS += vendor/kic-priv/keys/releasekey
endif
