GO_EASY_ON_ME = 1

LIBRARY_NAME = libtsssaver
libtsssaver_FILES = $(wildcard Library/*.m)
libtsssaver_FRAMEWORKS = CoreFoundation Foundation UIKit
libtsssaver_PRIVATE_FRAMEWORKS = IOKit
llibtsssaver_INSTALL_PATH = /usr/lib

APPLICATION_NAME = TSSSaver
TSSSaver_FILES = $(wildcard TSSSaver/*.m)
TSSSaver_FRAMEWORKS = UIKit CoreGraphics CoreFoundation
TSSSaver_PRIVATE_FRAMEWORKS = IOKit
TSSSaver_CODESIGN_FLAGS = -SEntitlements.xml
TSSSaver_LIBRARIES = tsssaver
TSSSaver_LDFLAGS = -lxml2
TSSSaver_CFLAGS=-I$(SYSROOT)/usr/include/libxml2

TWEAK_NAME = TSSSaverSB
TSSSaverSB_FILES = $(wildcard SpringBoard/*.xm) $(wildcard SpringBoard/*.m)
TSSSaverSB_FRAMEWORKS = UIKit CoreGraphics CoreFoundation
TSSSaverSB_LIBRARIES = tsssaver bulletin
TSSSaverSB_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 8.0
export ARCHS = armv7 arm64 arm64e
export ADDITIONAL_OBJCFLAGS = -fobjc-arc
export THEOS_OBJ_DIR_NAME = ../output
export ADDITIONAL_CFLAGS = -I./Library
export ADDITIONAL_LDFLAGS = -L$(THEOS_OBJ_DIR)

include $(THEOS)/makefiles/common.mk
include $(THEOS)/makefiles/library.mk
include $(THEOS_MAKE_PATH)/application.mk
include $(THEOS)/makefiles/tweak.mk

$(THEOS_OBJ_DIR)/%.storyboardc:: %.storyboard
	$(ECHO_COMPILING)xcrun -sdk iphoneos ibtool --errors --warnings --notices --output-format human-readable-text --module TSSSaver --target-device iphone --minimum-deployment-target 8.0 --compile "$@" "$<"$(ECHO_END)

before-TSSSaver-all:: $(THEOS_OBJ_DIR)/TSSSaver/LaunchScreen.storyboardc $(THEOS_OBJ_DIR)/TSSSaver/Main.storyboardc

stage::
	cp -r $(THEOS_OBJ_DIR)/TSSSaver/LaunchScreen.storyboardc $(THEOS_OBJ_DIR)/TSSsaver.app/LaunchScreen.storyboardc
	cp -r $(THEOS_OBJ_DIR)/TSSSaver/Main.storyboardc $(THEOS_OBJ_DIR)/TSSsaver.app/Main.storyboardc

after-install::
	install.exec "killall SpringBoard" || true
