export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:13.0
export SYSROOT = $(THEOS)/sdks/iPhoneOS14.1.sdk

FINALPACKAGE = 0 
DEBUG = 1

INSTALL_TARGET_PROCESSES = Preferences SpringBoard
SUBPROJECTS += src/Battery           # It works but preferences doesn't, animations either... :(
SUBPROJECTS += src/ControlCenter     # It works but has no animation, which i wanted...
SUBPROJECTS += src/Preferences       # Rebuild on process...

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

	
c:
	find . -name ".DS_Store" -delete
	rm -rf .theos/ build/
#Cleanup using; $make c
