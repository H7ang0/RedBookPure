TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = discover

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RedBookPure
RedBookPure_FILES = RedBookPure.x ReadBookPureSettingsViewController.m ThemeSettingsViewController.m ThemeManager.m UIButton+Layout.m PureLang.m AlertManager.m
RedBookPure_CFLAGS = -fobjc-arc
RedBookPure_FRAMEWORKS = UIKit Foundation CoreGraphics AVFoundation Photos

TWEAK_DEPENDS += applist
LIBRARIES += substrate

include $(THEOS_MAKE_PATH)/tweak.mk 