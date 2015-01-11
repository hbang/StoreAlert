TARGET = :clang::5.0
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = StoreAlert
StoreAlert_FILES = Tweak.x HBSAStorePermissionAlertItem.m
StoreAlert_FRAMEWORKS = UIKit
StoreAlert_PRIVATE_FRAMEWORKS = SpringBoardUI
StoreAlert_LIBRARIES = cephei
StoreAlert_LDFLAGS = -fobjc-arc

SUBPROJECTS = prefs

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences; sleep 0.2; sbopenurl prefs:root=StoreAlert"
else
	install.exec "spring"
endif
