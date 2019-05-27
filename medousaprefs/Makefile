include $(THEOS)/makefiles/common.mk

ARCHS = arm64 arm64e

BUNDLE_NAME = medousaprefs
medousaprefs_FILES = RNMRootListController.m
medousaprefs_INSTALL_PATH = /Library/PreferenceBundles
medousaprefs_FRAMEWORKS = UIKit
medousaprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/medousaprefs.plist$(ECHO_END)
