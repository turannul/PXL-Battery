TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PXLPrefs

PXLPrefs_FILES = XXXRootListController.m
PXLPrefs_FRAMEWORKS = UIKit
PXLPrefs_PRIVATE_FRAMEWORKS = Preferences
PXLPrefs_INSTALL_PATH = /Library/PreferenceBundles
PXLPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
