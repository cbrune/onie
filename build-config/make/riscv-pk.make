#-------------------------------------------------------------------------------
#
#  Copyright (C) 2018 Curt Brune <curt@brune.net>
#
#  SPDX-License-Identifier:     GPL-2.0
#
#-------------------------------------------------------------------------------
#
# This is a makefile fragment that defines the build of riscv-pk
#

RISCV_PK_VERSION	= e12593841af47b6b15c7de63804342ef87f271ce
RISCV_PK_TARBALL_0	= $(RISCV_PK_VERSION).tar.gz
RISCV_PK_TARBALL	= riscv-pk-$(RISCV_PK_VERSION).tar.gz
RISCV_PK_TARBALL_URLS	+= https://github.com/riscv/riscv-pk/archive
RISCV_PK_BUILD_DIR	= $(MBUILDDIR)/riscv-pk
RISCV_PK_DIR		= $(RISCV_PK_BUILD_DIR)/riscv-pk-$(RISCV_PK_VERSION)
RISCV_PK_EMBED_DIR	= $(RISCV_PK_BUILD_DIR)/build

RISCV_PK_SRCPATCHDIR	= $(PATCHDIR)/riscv-pk
RISCV_PK_DOWNLOAD_STAMP	= $(DOWNLOADDIR)/riscv-pk-download
RISCV_PK_SOURCE_STAMP	= $(STAMPDIR)/riscv-pk-source
RISCV_PK_CONFIGURE_STAMP= $(STAMPDIR)/riscv-pk-configure
RISCV_PK_BUILD_STAMP	= $(STAMPDIR)/riscv-pk-build
RISCV_PK_INSTALL_STAMP	= $(STAMPDIR)/riscv-pk-install
RISCV_PK_STAMP		= $(RISCV_PK_SOURCE_STAMP) \
			  $(RISCV_PK_CONFIGURE_STAMP) \
			  $(RISCV_PK_BUILD_STAMP) \
			  $(RISCV_PK_INSTALL_STAMP)

RISCV_PK_BBL		= $(IMAGEDIR)/$(MACHINE_PREFIX).bbl

PHONY += riscv-pk riscv-pk-download riscv-pk-source \
	 riscv-pk-configure riscv-pk-build riscv-pk-install riscv-pk-clean \
	 riscv-pk-download-clean

riscv-pk: $(RISCV_PK_STAMP)

DOWNLOAD += $(RISCV_PK_DOWNLOAD_STAMP)
riscv-pk-download: $(RISCV_PK_DOWNLOAD_STAMP)
$(RISCV_PK_DOWNLOAD_STAMP): $(PROJECT_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Getting upstream riscv-pk ===="
	$(Q) $(SCRIPTDIR)/fetch-package $(DOWNLOADDIR) $(UPSTREAMDIR) \
		$(RISCV_PK_TARBALL_0) $(RISCV_PK_TARBALL_URLS)
	$(Q) mv $(DOWNLOADDIR)/$(RISCV_PK_TARBALL_0) $(DOWNLOADDIR)/$(RISCV_PK_TARBALL)
	$(Q) touch $@

SOURCE += $(RISCV_PK_SOURCE_STAMP)
riscv-pk-source: $(RISCV_PK_SOURCE_STAMP)
$(RISCV_PK_SOURCE_STAMP): $(USER_TREE_STAMP) | $(RISCV_PK_DOWNLOAD_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Extracting upstream riscv-pk ===="
	$(Q) $(SCRIPTDIR)/extract-package $(RISCV_PK_BUILD_DIR) $(DOWNLOADDIR)/$(RISCV_PK_TARBALL)
	$(Q) touch $@

riscv-pk-configure: $(RISCV_PK_CONFIGURE_STAMP)
$(RISCV_PK_CONFIGURE_STAMP): $(RISCV_PK_SOURCE_STAMP) $(KERNEL_BUILD_STAMP) | $(DEV_SYSROOT_INIT_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "====  Configure riscv-pk-$(RISCV_PK_VERSION) ===="
	$(Q) rm -rf $(RISCV_PK_EMBED_DIR)
	$(Q) mkdir -p $(RISCV_PK_EMBED_DIR)
	$(Q) cd $(RISCV_PK_EMBED_DIR) && PATH='$(CROSSBIN):$(PATH)'	\
		$(RISCV_PK_DIR)/configure				\
		--prefix=$(RISCV_XTOOLS_INSTALL_DIR)			\
		--host=$(TARGET)					\
		--with-payload=$(KERNEL_IMAGE_FILE)
	$(Q) touch $@

ifndef MAKE_CLEAN
RISCV_PK_NEW_FILES = $(shell test -d $(RISCV_PK_DIR) && test -f $(RISCV_PK_BUILD_STAMP) && \
	              find -L $(RISCV_PK_DIR) -newer $(RISCV_PK_BUILD_STAMP) -type f \
			\! -name symlinks \! -name symlinks.o -print -quit)
endif

riscv-pk-build: $(RISCV_PK_BUILD_STAMP)
$(RISCV_PK_BUILD_STAMP): $(RISCV_PK_NEW_FILES) $(RISCV_PK_CONFIGURE_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "====  Building riscv-pk-$(RISCV_PK_VERSION) ===="
	$(Q) PATH='$(CROSSBIN):$(PATH)'	$(MAKE) -C $(RISCV_PK_EMBED_DIR)
	$(Q) touch $@

riscv-pk-install: $(RISCV_PK_INSTALL_STAMP)
$(RISCV_PK_INSTALL_STAMP): $(SYSROOT_INIT_STAMP) $(RISCV_PK_BUILD_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Installing riscv-pk in $(IMAGEDIR) ===="
	$(Q) cp -av $(RISCV_PK_EMBED_DIR)/bbl $(RISCV_PK_BBL)
	$(Q) touch $@

MACHINE_CLEAN += riscv-pk-clean
riscv-pk-clean:
	$(Q) rm -rf $(RISCV_PK_BUILD_DIR)
	$(Q) rm -f $(RISCV_PK_STAMP) $(RISCV_PK_BBL)
	$(Q) echo "=== Finished making $@ for $(PLATFORM)"

DOWNLOAD_CLEAN += riscv-pk-download-clean
riscv-pk-download-clean:
	$(Q) rm -f $(RISCV_PK_DOWNLOAD_STAMP) $(DOWNLOADDIR)/riscv-pk*

#-------------------------------------------------------------------------------
#
# Local Variables:
# mode: makefile-gmake
# End:
