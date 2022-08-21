export ARCHS = arm64 arm64e
export TARGET = iphone:clang:14.4:13.0
export SYSROOT = $(THEOS)/sdks/iPhoneOS14.4.sdk

INSTALL_TARGET_PROCESSES = SpringBoard
SUBPROJECTS += PXL/PXL_Battery
SUBPROJECTS += PXL/PXL_Prefs

include $(THEOS)/makefiles/common.mk
SUBPROJECTS += xxxxxx
include $(THEOS_MAKE_PATH)/aggregate.mk
