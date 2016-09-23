#-------------------------------------------------------------------------------
#
#  Copyright (C) 2016 Curt Brune <curt@cumulusnetworks.com>
#
#  SPDX-License-Identifier:     GPL-2.0
#
#-------------------------------------------------------------------------------
#
# This is a makefile fragment that defines the build of shim
#

SHIM_VERSION			= 0.9
SHIM_TARBALL			= shim-$(SHIM_VERSION).tar.bz2
SHIM_TARBALL_URLS		+= $(ONIE_MIRROR) https://github.com/rhinstaller/shim/releases/download/$(SHIM_VERSION)
SHIM_BUILD_DIR			= $(MBUILDDIR)/shim
SHIM_DIR			= $(SHIM_BUILD_DIR)/shim-$(SHIM_VERSION)

SHIM_SRCPATCHDIR		= $(PATCHDIR)/shim
SHIM_DOWNLOAD_STAMP		= $(DOWNLOADDIR)/shim-download
SHIM_SOURCE_STAMP		= $(STAMPDIR)/shim-source
SHIM_PATCH_STAMP		= $(STAMPDIR)/shim-patch
SHIM_BUILD_STAMP		= $(STAMPDIR)/shim-build
SHIM_STAMP			= $(SHIM_SOURCE_STAMP) \
				  $(SHIM_PATCH_STAMP) \
				  $(SHIM_BUILD_STAMP)

PHONY += shim shim-download shim-source shim-patch \
	shim-build shim-clean shim-download-clean

shim: $(SHIM_STAMP)

DOWNLOAD += $(SHIM_DOWNLOAD_STAMP)
shim-download: $(SHIM_DOWNLOAD_STAMP)
$(SHIM_DOWNLOAD_STAMP): $(PROJECT_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Getting upstream shim ===="
	$(Q) $(SCRIPTDIR)/fetch-package $(DOWNLOADDIR) $(UPSTREAMDIR) \
		$(SHIM_TARBALL) $(SHIM_TARBALL_URLS)
	$(Q) touch $@

SOURCE += $(SHIM_SOURCE_STAMP)
shim-source: $(SHIM_SOURCE_STAMP)
$(SHIM_SOURCE_STAMP): $(TREE_STAMP) $(SHIM_DOWNLOAD_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Extracting upstream shim ===="
	$(Q) $(SCRIPTDIR)/extract-package $(SHIM_BUILD_DIR) $(DOWNLOADDIR)/$(SHIM_TARBALL)
	$(Q) touch $@

shim-patch: $(SHIM_PATCH_STAMP)
$(SHIM_PATCH_STAMP): $(SHIM_SRCPATCHDIR)/* $(SHIM_SOURCE_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Patching shim ===="
	$(Q) $(SCRIPTDIR)/apply-patch-series $(SHIM_SRCPATCHDIR)/series $(SHIM_DIR)
	$(Q) touch $@

ifndef MAKE_CLEAN
SHIM_NEW_FILES = $(shell test -d $(SHIM_DIR) && test -f $(SHIM_BUILD_STAMP) && \
	              find -L $(SHIM_DIR) -newer $(SHIM_BUILD_STAMP) -type f -print -quit)
endif

shim-build: $(SHIM_BUILD_STAMP)
$(SHIM_BUILD_STAMP): $(SHIM_PATCH_STAMP) $(SHIM_NEW_FILES) $(GNU_EFI_INSTALL_STAMP) \
			$(PESIGN_INSTALL_STAMP) | $(DEV_SYSROOT_INIT_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "====  Building shim-$(SHIM_VERSION) ===="
	$(Q) PATH='$(CROSSBIN):$(PESIGN_BIN_DIR):$(PATH)'	\
		$(MAKE) -C $(SHIM_DIR) \
			CROSS_COMPILE=$(CROSSPREFIX) \
			RELEASE=onie \
			LIB_PATH="$(DEV_SYSROOT)/usr/lib" \
			EFI_PATH="$(GNU_EFI_LIB_PATH)" \
			EFI_INCLUDE="$(GNU_EFI_INCLUDE)"
	$(Q) touch $@

USERSPACE_CLEAN += shim-clean
shim-clean:
	$(Q) rm -rf $(SHIM_BUILD_DIR)
	$(Q) rm -f $(SHIM_STAMP)
	$(Q) echo "=== Finished making $@ for $(PLATFORM)"

DOWNLOAD_CLEAN += shim-download-clean
shim-download-clean:
	$(Q) rm -f $(SHIM_DOWNLOAD_STAMP) $(DOWNLOADDIR)/$(SHIM_TARBALL)

#-------------------------------------------------------------------------------
#
# Local Variables:
# mode: makefile-gmake
# End:
