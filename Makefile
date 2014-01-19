TARGET = :clang::5.0
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = StoreAlert
StoreAlert_FILES = Tweak.x HBSAStorePermissionAlertItem.m
StoreAlert_FRAMEWORKS = UIKit
StoreAlert_PRIVATE_FRAMEWORKS = SpringBoardUI

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "spring"
