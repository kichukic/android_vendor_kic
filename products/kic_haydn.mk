#
# KIC OS for Xiaomi Mi 11X Pro / Redmi K40 Pro / Mi 11i (haydn)
#

# Device
$(call inherit-product, device/xiaomi/haydn/device.mk)

# LineageOS base
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# KIC OS
$(call inherit-product, vendor/kic/config/common.mk)

PRODUCT_NAME := kic_haydn
PRODUCT_DEVICE := haydn
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := M2012K11G
PRODUCT_MANUFACTURER := Xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="haydn_global-user 14 UKQ1.231207.002 V816.0.19.0.UKKMIXM release-keys" \
    BuildFingerprint=Xiaomi/haydn_global/haydn:14/UKQ1.231207.002/V816.0.19.0.UKKMIXM:user/release-keys \
    DeviceProduct=haydn \
    SystemName=haydn_global

# KIC OS device id
PRODUCT_SYSTEM_EXT_PROPERTIES += ro.kic.device=haydn
