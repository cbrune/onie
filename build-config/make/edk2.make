#-------------------------------------------------------------------------------
#
#  Copyright (C) 2016 Curt Brune <curt@cumulusnetworks.com>
#
#  SPDX-License-Identifier:     GPL-2.0
#
#-------------------------------------------------------------------------------
#
# makefile fragment that defines the build of the edk2
#

#-------------------------------------------------------------------------------

EDK2_RELEASE		?= UDK2017-ea2f21e3f
EDK2_CONFIG 		= conf/edk2/$(EDK2_RELEASE)/$(ONIE_ARCH).config
EDK2_BUILD_DIR		= $(MBUILDDIR)/edk2-build
EDK2DIR   		= $(EDK2_BUILD_DIR)/edk2
export EDK2DIR

EDK2_CC			?= /usr/bin/gcc
EDK2_CXX		?= /usr/bin/g++
GCC_VERSION_PARTS	= $(shell $(EDK2_CC) --version | head -1 | sed -e 's/^.* //' -e 's/\./ /g')
EDK2_TOOLCHAIN		= GCC$(word 1,$(GCC_VERSION_PARTS))$(word 2,$(GCC_VERSION_PARTS))
EDK2_THREADNUMBER	= 8

EDK2_TARGET_FILE	= $(EDK2DIR)/Conf/target.txt

EDK2_TARBALL		?= edk2-$(EDK2_RELEASE).tar.xz
EDK2_TARBALL_URLS	+= $(ONIE_MIRROR)/edk2

EDK2_SRCPATCHDIR	= $(PATCHDIR)/edk2/$(EDK2_RELEASE)
MACHINE_EDK2_PATCHDIR	?= $(MACHINEDIR)/edk2
EDK2_PATCHDIR		= $(EDK2_BUILD_DIR)/patch

EDK2_DOWNLOAD_STAMP	= $(DOWNLOADDIR)/edk2-download
EDK2_SOURCE_STAMP	= $(STAMPDIR)/edk2-source
EDK2_PATCH_STAMP	= $(STAMPDIR)/edk2-patch
EDK2_BUILD_STAMP	= $(STAMPDIR)/edk2-build
EDK2_OVMF_STAMP		= $(STAMPDIR)/edk2-ovmf
EDK2_STAMP		= $(EDK2_DOWNLOAD_STAMP) \
			  $(EDK2_SOURCE_STAMP) \
			  $(EDK2_PATCH_STAMP) \
			  $(EDK2_BUILD_STAMP) \
			  $(EDK2_OVMF_STAMP) \

EDK2			= $(EDK2_STAMP)

PHONY += edk2 edk2-download edk2-download-clean
PHONY += edk2-source edk2-patch edk2-config
PHONY += edk2-build edk2-ovmf edk2-clean

#-------------------------------------------------------------------------------

# Environment variables needed by the EDK2 build system
EDK_TOOLS_PATH		= $(EDK2DIR)/BaseTools
export EDK_TOOLS_PATH

# Wrapper script for invoking edk2 tools with the edk2 build
# environment variables set.
EDK2_WRAPPER		= $(SCRIPTDIR)/edk2-cmd

# Build command with arguments to apply for every invocation
EDK2_BUILD_CMD	= $(EDK2_WRAPPER) build \
			--arch=$(EDK2_ARCH) \
			--tagname=$(EDK2_TOOLCHAIN) \
			-n $(EDK2_THREADNUMBER)

#-------------------------------------------------------------------------------

edk2: $(EDK2_STAMP)

#---

DOWNLOAD += $(EDK2_DOWNLOAD_STAMP)
edk2-download: $(EDK2_DOWNLOAD_STAMP)
$(EDK2_DOWNLOAD_STAMP): $(PROJECT_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Getting EDK2 ===="
	$(Q) $(SCRIPTDIR)/fetch-package $(DOWNLOADDIR) $(UPSTREAMDIR) \
		$(EDK2_TARBALL) $(EDK2_TARBALL_URLS)
	$(Q) touch $@

SOURCE += $(EDK2_PATCH_STAMP)
edk2-source: $(EDK2_SOURCE_STAMP)
$(EDK2_SOURCE_STAMP): $(TREE_STAMP) $(EDK2_DOWNLOAD_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Extracting EDK2 ===="
	$(Q) $(SCRIPTDIR)/extract-package $(EDK2_BUILD_DIR) $(DOWNLOADDIR)/$(EDK2_TARBALL)
	$(Q) cd $(EDK2_BUILD_DIR) && ln -s edk2-$(EDK2_RELEASE) edk2
	$(Q) touch $@

edk2-patch: $(EDK2_PATCH_STAMP)
$(EDK2_PATCH_STAMP): $(EDK2_SRCPATCHDIR)/* $(EDK2_SOURCE_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== patching  EDK2 ===="
	$(Q) $(SCRIPTDIR)/apply-patch-series $(EDK2_SRCPATCHDIR)/series $(EDK2DIR)
	$(Q) touch $@

ifndef MAKE_CLEAN
EDK2_NEW_FILES	= \
	$(shell test -d $(EDK2DIR) && test -f $(EDK2_INSTALL_STAMP) && \
	  find -L $(EDK2DIR) -mindepth 1 -newer $(EDK2_INSTALL_STAMP) \
	    -type f -print -quit 2>/dev/null)
endif

edk2-build: $(EDK2_BUILD_STAMP)
$(EDK2_BUILD_STAMP): $(EDK2_PATCH_STAMP) $(EDK2_NEW_FILES) | $(XTOOLS_BUILD_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Building edk2 ===="
	$(Q) CC=$(EDK2_CC) CXX=$(EDK2_CXX) \
		$(MAKE) -j1 -C $(EDK2DIR)/BaseTools
	$(Q) cd $(EDK2DIR) && . ./edksetup.sh
	$(Q) touch $@

edk2-ovmf: $(EDK2_OVMF_STAMP)
$(EDK2_OVMF_STAMP): $(EDK2_BUILD_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Building edk2-ovmf ===="
	$(Q) +$(EDK2_BUILD_CMD) \
		-D NETWORK_IP6_ENABLE \
		-D HTTP_BOOT_ENABLE \
		--platform=OvmfPkg/OvmfPkgX64.dsc
	$(Q) touch $@

CLEAN += edk2-clean
edk2-clean:
	$(Q) rm -rf $(EDK_BUILD_DIR)
	$(Q) rm -f $(EDK2_STAMP)
	$(Q) echo "=== Finished making $@ for $(PLATFORM)"

DOWNLOAD_CLEAN += edk2-download-clean
edk2-download-clean:
	$(Q) rm -f $(EDK2_DOWNLOAD_STAMP) $(DOWNLOADDIR)/$(EDK2_TARBALL)

#-------------------------------------------------------------------------------
#
# Local Variables:
# mode: makefile-gmake
# End:
