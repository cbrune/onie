#-------------------------------------------------------------------------------
#
#  Copyright (C) 2016 Curt Brune <curt@cumulusnetworks.com>
#
#  SPDX-License-Identifier:     GPL-2.0
#
#-------------------------------------------------------------------------------
#
# This is a makefile fragment that defines the build of onie-uefi
#

ONIE_UEFI_SOURCE_STAMP		= $(STAMPDIR)/onie-uefi-source
ONIE_UEFI_BUILD_STAMP		= $(STAMPDIR)/onie-uefi-build
ONIE_UEFI_STAMP			= $(ONIE_UEFI_SOURCE_STAMP) \
				  $(ONIE_UEFI_BUILD_STAMP)

ONIE_UEFI_ROOT_DIR		= $(realpath ../uefi)
ONIE_UEFI_SRC_DIR		= $(ONIE_UEFI_ROOT_DIR)/src
ONIE_UEFI_INCLUDE_DIR		= $(ONIE_UEFI_ROOT_DIR)/include

ONIE_UEFI_BUILD_DIR		= $(MBUILDDIR)/onie-uefi
ONIE_UEFI_BUILD_INCLUDE		= $(ONIE_UEFI_BUILD_DIR)/include
ONIE_UEFI_BUILD_INFO		= $(ONIE_UEFI_BUILD_INCLUDE)/onie-build.h

PHONY += onie-uefi onie-uefi-source onie-uefi-build onie-uefi-clean

onie-uefi: $(ONIE_UEFI_STAMP)

SOURCE += $(ONIE_UEFI_SOURCE_STAMP)
onie-uefi-source: $(ONIE_UEFI_SOURCE_STAMP)
$(ONIE_UEFI_SOURCE_STAMP): $(TREE_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Generating onie-uefi build directory ===="
	$(Q) rm -rf $(ONIE_UEFI_BUILD_DIR)
	$(Q) mkdir -p $(ONIE_UEFI_BUILD_DIR) $(ONIE_UEFI_BUILD_INCLUDE)
	$(Q) touch $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo "/* This file is auto-generated.  Do not edit. */" >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo "#ifndef ONIE_UEFI_BUILD_H__" >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo "#define ONIE_UEFI_BUILD_H__" >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo "#define ONIE_UEFI_BUILD_VERSION       L\"$(LSB_RELEASE_TAG)\"" >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo "#define ONIE_UEFI_BUILD_DATE		 L\"$$(date -Imin)\"" >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo "#define ONIE_UEFI_BUILD_VENDOR_ID	 L\"$(VENDOR_ID)\"" >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo "#define ONIE_UEFI_BUILD_PLATFORM	 L\"$(RUNTIME_ONIE_PLATFORM)\"" >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo "#define ONIE_UEFI_BUILD_MACHINE	 L\"$(RUNTIME_ONIE_MACHINE)\"" >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo "#define ONIE_UEFI_BUILD_MACHINE_REV	 L\"$(MACHINE_REV)\"" >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo "#define ONIE_UEFI_BUILD_ARCH		 L\"$(ARCH)\"" >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo "#define ONIE_UEFI_BUILD_SWITCH_ASIC	 L\"$(SWITCH_ASIC_VENDOR)\"" >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) echo "#endif /* ONIE_UEFI_BUILD_H__ */" >> $(ONIE_UEFI_BUILD_INFO)
	$(Q) touch $@

ifndef MAKE_CLEAN
ONIE_UEFI_NEW_FILES = $(shell test -f $(ONIE_UEFI_BUILD_STAMP) && \
	              find -L $(ONIE_UEFI_ROOT_DIR) -newer $(ONIE_UEFI_BUILD_STAMP) -type f -print -quit)
endif

onie-uefi-build: $(ONIE_UEFI_BUILD_STAMP)
$(ONIE_UEFI_BUILD_STAMP): $(ONIE_UEFI_SOURCE_STAMP) $(SHIM_BUILD_STAMP) \
				$(ONIE_UEFI_NEW_FILES) | $(DEV_SYSROOT_INIT_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "====  Building onie-uefi ===="
	$(Q) PATH='$(CROSSBIN):$(PESIGN_BIN_DIR):$(PATH)'	\
		$(MAKE) -C $(ONIE_UEFI_ROOT_DIR) \
			CROSS_COMPILE=$(CROSSPREFIX) \
			LIB_PATH="$(DEV_SYSROOT)/usr/lib" \
			EFI_PATH="$(GNU_EFI_LIB_PATH)" \
			EFI_INCLUDE="$(GNU_EFI_INCLUDE)" \
			SHIM_DIR="$(SHIM_DIR)" \
			ONIE_UEFI_BUILD_INCLUDE="$(ONIE_UEFI_BUILD_INCLUDE)" \
			OUTPUT_DIR="$(ONIE_UEFI_BUILD_DIR)"

	$(Q) touch $@

USERSPACE_CLEAN += onie-uefi-clean
onie-uefi-clean:
	$(Q) rm -rf $(ONIE_UEFI_BUILD_DIR)
	$(Q) rm -f $(ONIE_UEFI_STAMP)
	$(Q) echo "=== Finished making $@ for $(PLATFORM)"

#-------------------------------------------------------------------------------
#
# Local Variables:
# mode: makefile-gmake
# End:
