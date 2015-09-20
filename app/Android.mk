#
# Copyright (C) 2011-2013 The Android-x86 Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#

LOCAL_PATH := $(call my-dir)
LOCAL_APPS := $(subst $(LOCAL_PATH)/,,$(wildcard $(LOCAL_PATH)/*$(COMMON_ANDROID_PACKAGE_SUFFIX)))

define include-app
include $$(CLEAR_VARS)

LOCAL_MODULE := $$(basename $(1))
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_SUFFIX := $$(suffix $(1))
LOCAL_SRC_FILES := $(1)
LOCAL_MODULE_CLASS := APPS
LOCAL_CERTIFICATE := PRESIGNED
include $$(BUILD_PREBUILT)

LOCAL_LIBS := $$(shell zipinfo -1 $$(LOCAL_PATH)/$(1) | grep ^lib/ | grep -v /$$$$)
LOCAL_X86_LIBS := $$(filter lib/x86/%,$$(LOCAL_LIBS))
LOCAL_ARM_LIBS := $$(filter lib/armeabi/%,$$(LOCAL_LIBS))
LOCAL_ARMV7_LIBS := $$(filter lib/armeabi-v7a/%,$$(LOCAL_LIBS))
LOCAL_LIBS := $$(if $$(LOCAL_X86_LIBS),$$(LOCAL_X86_LIBS),$$(if $$(LOCAL_ARMV7_LIBS),$$(LOCAL_ARMV7_LIBS),$$(LOCAL_ARM_LIBS)))
ifneq ($$(LOCAL_LIBS),)
INSTALLED_LIBS := $$(addprefix $$(TARGET_OUT_SHARED_LIBRARIES)/$$(if $$(LOCAL_X86_LIBS),,arm/),$$(notdir $$(firstword $$(LOCAL_LIBS))))
$$(INSTALLED_LIBS): PRIVATE_LIBS := $$(LOCAL_LIBS)
$$(INSTALLED_LIBS): $$(LOCAL_PATH)/$(1)
	@mkdir -p $$(@D) && unzip -joDDd $$(@D) $$< $$(PRIVATE_LIBS)
$$(LOCAL_BUILT_MODULE): $$(INSTALLED_LIBS)
endif

ALL_DEFAULT_INSTALLED_MODULES += $$(LOCAL_INSTALLED_MODULE)
endef

$(foreach a,$(LOCAL_APPS),$(eval $(call include-app,$(a))))
