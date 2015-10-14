include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = StoreAlert
StoreAlert_FILES = $(wildcard *.m)
StoreAlert_INSTALL_PATH = /Library/PreferenceBundles
StoreAlert_FRAMEWORKS = UIKit
StoreAlert_PRIVATE_FRAMEWORKS = Preferences
StoreAlert_LIBRARIES = cepheiprefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/StoreAlert.plist$(ECHO_END)
