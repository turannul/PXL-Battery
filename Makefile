export ARCHS = arm64 arm64e
export TARGET = iphone:clang:14.8:13.0
export SYSROOT = $(THEOS)/sdks/iPhoneOS14.4.sdk

THEOS_DEVICE_IP= 1.1.1.9 #127.0.0.1 is another option but wired
THEOS_DEVICE_PORT= 22 #unc0ver 
#2222 Taurine/Odyssey(ra1n) 
#44 checkra1n

INSTALL_TARGET_PROCESSES = SpringBoard
SUBPROJECTS += PXL/PXL_Battery           #%80 Completed.
SUBPROJECTS += PXL/PXL_CC_Modules/ON-OFF #%100 Completed.
#SUBPROJECTS += PXL/PXL_CC_Modules/LPM   #%0 Completed.
SUBPROJECTS += PXL/PXL_Prefs             #%80 Completed.

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk