export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:13.0
export SYSROOT = $(THEOS)/sdks/iPhoneOS14.1.sdk

FINALPACKAGE = 0 
DEBUG = 1

INSTALL_TARGET_PROCESSES = Preferences SpringBoard
SUBPROJECTS += PXL/PXL_Battery # It works but preferences doesn't, animations either... :(
SUBPROJECTS += PXL/PXL_CC      # It works but has no animation, which i wanted...
#SUBPROJECTS += PXL/PXL_Prefs   # Completely broken

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

	
c:
	find . -name ".DS_Store" -delete
	rm -rf .theos/ build/
#Cleanup using; $make c