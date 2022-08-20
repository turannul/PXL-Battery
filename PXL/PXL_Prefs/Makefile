TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = pxl

pxl_FILES = ryRootListController.m $(wildcard functions/*.m)
pxl_FRAMEWORKS = UIKit
pxl_PRIVATE_FRAMEWORKS = Preferences
pxl_EXTRA_FRAMEWORKS += Cephei CepheiPrefs
pxl_INSTALL_PATH = /Library/PreferenceBundles
pxl_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
