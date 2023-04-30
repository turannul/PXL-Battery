export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:13.0
export SYSROOT = $(THEOS)/sdks/iPhoneOS14.1.sdk

FINALPACKAGE = 1
DEBUG = 0

INSTALL_TARGET_PROCESSES = SpringBoard

SUBPROJECTS += PXL/PXL_Battery           # It works.  Completed:%75 (See the README.md)
SUBPROJECTS += PXL/PXL_CC                # It works.  Compeleted:%100
SUBPROJECTS += PXL/PXL_Prefs             # It works.  Compeleted:%100

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
	
c:
	find . -name ".DS_Store" -delete
	rm -rf .theos/ build/
#Clean up using 'make c'
