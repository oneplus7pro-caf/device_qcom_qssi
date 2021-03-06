#For QSSI, we build only the system image. Here we explicitly set the images
#we build so there is no confusion.

# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

#Enable product partition Native I/F. It is automatically set to current if
#the shipping API level for the target is greater than 29
PRODUCT_PRODUCT_VNDK_VERSION := current

#Enable product partition Java I/F. It is automatically set to true if
#the shipping API level for the target is greater than 29
PRODUCT_ENFORCE_PRODUCT_PARTITION_INTERFACE := true

PRODUCT_BUILD_SYSTEM_IMAGE := true
PRODUCT_BUILD_SYSTEM_OTHER_IMAGE := false
PRODUCT_BUILD_VENDOR_IMAGE := false
PRODUCT_BUILD_SYSTEM_EXT_IMAGE := false
PRODUCT_BUILD_ODM_IMAGE := false
PRODUCT_BUILD_CACHE_IMAGE := false
PRODUCT_BUILD_USERDATA_IMAGE := false

#Also, there is no need to build an OTA package as this will be done later
#when we combine this system build with the non-system images.
TARGET_SKIP_OTA_PACKAGE := true

# Enable AVB
BOARD_AVB_ENABLE := true
BOARD_AVB_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --set_hashtree_disabled_flag --flags 2

# Inherit proprietary blobs
$(call inherit-product, vendor/oneplus/guacamole/system/guacamole-system.mk)

# Inherit Gapps.
GAPPS_VARIANT := nano
$(call inherit-product, vendor/opengapps/build/opengapps-packages.mk)
GAPPS_PRODUCT_PACKAGES += \
    	Chrome \
	PrebuiltBugle \
	CalculatorGoogle \
	GoogleContacts \
	LatinImeGoogle \
	PrebuiltDeskClockGoogle \
	WebViewGoogle \
	CalendarGooglePrebuilt \
	GoogleDialer

GAPPS_EXCLUDED_PACKAGES := Velvet
GAPPS_FORCE_PACKAGE_OVERRIDES := true
GAPPS_FORCE_WEBVIEW_OVERRIDES := true
GAPPS_FORCE_MMS_OVERRIDES := true
GAPPS_FORCE_DIALER_OVERRIDES := true
GAPPS_PACKAGE_OVERRIDES := LatinImeGoogle

# Retain the earlier default behavior i.e. ota config (dynamic partition was disabled if not set explicitly), so set
# SHIPPING_API_LEVEL to 28 if it was not set earlier (this is generally set earlier via build.sh per-target)
SHIPPING_API_LEVEL := 28

$(call inherit-product-if-exists, vendor/qcom/defs/product-defs/system/cne_url*.mk)

BOARD_DYNAMIC_PARTITION_ENABLE := false
$(call inherit-product, build/make/target/product/product_launched_with_p.mk)

PRODUCT_BUILD_RAMDISK_IMAGE := false
PRODUCT_BUILD_PRODUCT_IMAGE := false

PRODUCT_SOONG_NAMESPACES += \
    hardware/google/av \
    hardware/google/interfaces

VENDOR_QTI_PLATFORM := msmnile
VENDOR_QTI_DEVICE := qssi

#QSSI configuration
#Single system image project structure
TARGET_USES_QSSI := true

TARGET_USES_NEW_ION := true

ENABLE_AB ?= true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

PRODUCT_PACKAGES += \
    otapreopt_script

TARGET_DEFINES_DALVIK_HEAP := true
$(call inherit-product, device/qcom/qssi/common64.mk)

#Inherit all except heap growth limit from phone-xhdpi-2048-dalvik-heap.mk
PRODUCT_PROPERTY_OVERRIDES  += \
	dalvik.vm.heapstartsize=8m \
	dalvik.vm.heapsize=512m \
	dalvik.vm.heaptargetutilization=0.75 \
	dalvik.vm.heapminfree=512k \
	dalvik.vm.heapmaxfree=8m

PRODUCT_NAME := $(VENDOR_QTI_DEVICE)
PRODUCT_DEVICE := $(VENDOR_QTI_DEVICE)
PRODUCT_BRAND := qti
PRODUCT_MODEL := qssi system image for arm64

#Initial bringup flags
TARGET_USES_AOSP := false
TARGET_USES_AOSP_FOR_AUDIO := false
TARGET_USES_QCOM_BSP := false

# RRO configuration
TARGET_USES_RRO := true

TARGET_USES_NQ_NFC := false

# default is nosdcard, S/W button enabled in resource
PRODUCT_CHARACTERISTICS := nosdcard
BOARD_FRP_PARTITION_NAME := frp

#Android EGL implementation
PRODUCT_PACKAGES += libGLES_android

PRODUCT_BOOT_JARS += tcmiface
PRODUCT_BOOT_JARS += telephony-ext
PRODUCT_PACKAGES += telephony-ext

TARGET_ENABLE_QC_AV_ENHANCEMENTS := false

TARGET_SYSTEM_PROP += device/qcom/qssi/system.prop

TARGET_DISABLE_DASH := true
TARGET_DISABLE_QTI_VPP := true

ifneq ($(TARGET_DISABLE_DASH), true)
    PRODUCT_BOOT_JARS += qcmediaplayer
endif

#Project is missing on sdm845, comment it for now
#ifneq ($(strip $(QCPATH)),)
#    PRODUCT_BOOT_JARS += libprotobuf-java_mls
#endif

PRODUCT_PACKAGES += android.hardware.media.omx@1.0-impl

# Audio configuration file
-include $(TOPDIR)vendor/qcom/opensource/audio-hal/primary-hal/configs/qssi/qssi.mk
-include $(TOPDIR)vendor/qcom/opensource/commonsys/audio/configs/qssi/qssi.mk
AUDIO_FEATURE_ENABLED_SVA_MULTI_STAGE := true
USE_LIB_PROCESS_GROUP := true

PRODUCT_PACKAGES += fs_config_files

ifeq ($(ENABLE_AB), true)
#A/B related packages
PRODUCT_PACKAGES += update_engine \
    update_engine_client \
    update_verifier \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-service

PRODUCT_HOST_PACKAGES += \
    brillo_update_payload

#Boot control HAL test app
PRODUCT_PACKAGES_DEBUG += bootctl
endif

#Healthd packages
PRODUCT_PACKAGES += \
    android.hardware.health@1.0-impl \
    android.hardware.health@1.0-convert \
    android.hardware.health@1.0-service \
    libhealthd.msm

DEVICE_FRAMEWORK_MANIFEST_FILE := device/qcom/qssi/framework_manifest.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := vendor/qcom/opensource/core-utils/vendor_framework_compatibility_matrix.xml

#audio related module
PRODUCT_PACKAGES += libvolumelistener

# Display/Graphics
PRODUCT_PACKAGES += \
    android.hardware.configstore@1.0-service \
    android.hardware.broadcastradio@1.0-impl

# Camera configuration file. Shared by passthrough/binderized camera HAL
PRODUCT_PACKAGES += camera.device@3.2-impl
PRODUCT_PACKAGES += camera.device@1.0-impl
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-impl

# Enable binderized camera HAL
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-service_64

# Context hub HAL
PRODUCT_PACKAGES += \
    android.hardware.contexthub@1.0-impl.generic \
    android.hardware.contexthub@1.0-service

# system prop for enabling QFS (QTI Fingerprint Solution)
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.qfp=true

# USB default HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.0-service

#PASR HAL and APP
PRODUCT_PACKAGES += \
    vendor.qti.power.pasrmanager@1.0-service \
    vendor.qti.power.pasrmanager@1.0-impl \
    pasrservice

# Kernel modules install path
KERNEL_MODULES_INSTALL := dlkm
KERNEL_MODULES_OUT := out/target/product/$(PRODUCT_NAME)/$(KERNEL_MODULES_INSTALL)/lib/modules

ifneq ($(strip $(TARGET_BUILD_VARIANT)),user)
PRODUCT_COPY_FILES += \
    device/qcom/qssi/init.qcom.testscripts.sh:$(TARGET_COPY_OUT_PRODUCT)/etc/init.qcom.testscripts.sh
endif

PRODUCT_COPY_FILES += \
    device/qcom/qssi/public.libraries.product-qti.txt:$(TARGET_COPY_OUT_PRODUCT)/etc/public.libraries-qti.txt

# copy system_ext specific whitelisted libraries to system_ext/etc
PRODUCT_COPY_FILES += \
    device/qcom/qssi/public.libraries.system_ext-qti.txt:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/public.libraries-qti.txt

# bootanimation
PRODUCT_COPY_FILES += \
    device/qcom/qssi/bootanimation/bootanimation.zip:$(TARGET_COPY_OUT_PRODUCT)/media/bootanimation.zip

#Enable full treble flag
PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_VENDOR_MOVE_ENABLED := true
PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true

ifneq ($(strip $(TARGET_USES_RRO)),true)
DEVICE_PACKAGE_OVERLAYS += device/qcom/qssi/overlay
endif

#Enable vndk-sp Libraries
PRODUCT_PACKAGES += vndk_package

PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE:=true

TARGET_MOUNT_POINTS_SYMLINKS := false

TARGET_USES_MKE2FS := true

TARGET_USES_QCOM_DISPLAY_BSP := true

ifeq ($(TARGET_USES_NEW_ION),true)
AUDIO_FEATURE_ENABLED_DLKM := true
else
AUDIO_FEATURE_ENABLED_DLKM := false
endif

# Include mainline components and QSSI whitelist
ifeq (true,$(call math_gt_or_eq,$(SHIPPING_API_LEVEL),29))
  $(call inherit-product, device/qcom/qssi/qssi_whitelist.mk)
  PRODUCT_ARTIFACT_PATH_REQUIREMENT_IGNORE_PATHS := /system/system_ext/
  PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := true
endif

###################################################################################
# This is the End of target.mk file.
# Now, Pickup other split makefiles:
###################################################################################
$(call inherit-product-if-exists, vendor/qcom/defs/product-defs/system/*.mk)
$(call inherit-product-if-exists, vendor/qcom/defs/board-defs/system/*.mk)
###################################################################################
