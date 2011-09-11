SDKVERSION=4.3
include theos/makefiles/common.mk

BUNDLE_NAME = folderlockfreesettings
folderlockfreesettings_FILES = folderlockfreesettings.mm
folderlockfreesettings_INSTALL_PATH = /Library/PreferenceBundles
folderlockfreesettings_FRAMEWORKS = UIKit
folderlockfreesettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/folderlockfreesettings.plist$(ECHO_END)
