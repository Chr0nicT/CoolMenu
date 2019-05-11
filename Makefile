include $(THEOS)/makefiles/common.mk


ARCHS=arm64 arm64e
TWEAK_NAME = CoolMenu
CoolMenu_CFLAGS = -fobjc-arc
CoolMenu_FILES = Tweak.xm


include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
