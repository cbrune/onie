#
#  Copyright (C) 2016 Curt Brune <curt@brune.net>
#
#  SPDX-License-Identifier:     GPL-2.0
#
#  RISC-V 64 bit Architecture and Toolchain Setup
#

# For now going with an out of tree toolchain for riscv from
# https://github.com/riscv/riscv-gnu-toolchain
#
# The target of that toolchain is riscv64-unknown-linux-gnu.

# Disable building the toolchain
XTOOLS_ENABLE = no

# Default toolchain install directory is /opt/riscv
RISCV_XTOOLS_INSTALL_DIR ?= /opt/riscv

ARCH        ?= riscv64
TARGET	    ?= riscv64-unknown-linux-gnu
CROSSPREFIX ?= $(TARGET)-
CROSSBIN    ?= $(RISCV_XTOOLS_INSTALL_DIR)/bin

GCC_VERSION := 8.2.0

# Set libc type and version - the version need to be kept in sync with
# the installed toolchain from $(RISCV_XTOOLS_INSTALL_DIR).
XTOOLS_LIBC = glibc
XTOOLS_LIBC_VERSION = 2.26
XTOOLS_VERSION = $(TARGET)-$(XTOOLS_LIBC)-$(XTOOLS_LIBC_VERSION)

#
# Console parameters
#
# These are passed to the ONIE Linux kernel and the demo OS kernel (in
# other words, everything that uses the console).  The default values
# are defined here.  They can be overridden by the platform's
# machine.make.
#
# CONSOLE_DEV is 0 or 1, corresponding to Linux /dev/ttyS[01].
#
# CONSOLE_SPEED is what you think it is.  We really like it fast
# because this is the 21st century.
#
CONSOLE_SPEED ?= 115200
CONSOLE_DEV ?= 0

KERNEL_ARCH		= riscv
KERNEL_IMAGE_FILE	= $(LINUX_BOOTDIR)/bzImage
KERNEL_INSTALL_DEPS	+= $(KERNEL_VMLINUZ_INSTALL_STAMP)

STRACE_ENABLE ?= no

# Disable Grub support by default. a machine make file can override this
GRUB_ENABLE ?= no

# Disable UEFI support by default. a machine make file can override this
UEFI_ENABLE ?= no
ifeq ($(UEFI_ENABLE),yes)
  # Set the target firmware type.  Possible values are "uefi"
  FIRMWARE_TYPE = uefi
endif

ifeq ($(UEFI_ENABLE),yes)
  PLATFORM_IMAGE_COMPLETE = $(IMAGE_UPDATER_STAMP) $(RECOVERY_ISO_STAMP)
else
  PLATFORM_IMAGE_COMPLETE = $(IMAGE_UPDATER_STAMP)
endif

PXE_EFI64_ENABLE ?= no

ifeq ($(PXE_EFI64_ENABLE),yes)
  PLATFORM_IMAGE_COMPLETE += $(PXE_EFI64_STAMP)
endif

UPDATER_IMAGE_PARTS = $(RISCV_PK_BBL) $(UPDATER_INITRD)
UPDATER_IMAGE_PARTS_COMPLETE = $(RISCV_PK_INSTALL_STAMP) $(UPDATER_INITRD)

DEMO_IMAGE_PARTS = $(DEMO_KERNEL_VMLINUZ) $(DEMO_SYSROOT_CPIO_XZ)
DEMO_IMAGE_PARTS_COMPLETE = $(DEMO_KERNEL_COMPLETE_STAMP) $(DEMO_SYSROOT_CPIO_XZ)
DEMO_ARCH_BINS = $(DEMO_OS_BIN) $(DEMO_DIAG_BIN)

# Include MTD utilities
MTDUTILS_ENABLE ?= yes

# Default to GPT
PARTITION_TYPE ?= gpt

# Include the GPT partitioning tools
GPT_ENABLE = yes

# gptfdisk requires C++
REQUIRE_CXX_LIBS = yes

# Include the GNU parted partitioning tools
PARTED_ENABLE = yes

# Include ext3/4 file system tools
EXT3_4_ENABLE = yes

# Default to include the i2ctools.  A particular machine.make can
# override this.
I2CTOOLS_ENABLE ?= yes

# Include lvm2 tools (needed for parted)
LVM2_ENABLE = yes
# Currently armv8a requires a special version of lvm2
# LVM2_VERSION ?= 2_02_155

# Include ethtool by default
ETHTOOL_ENABLE ?= yes

# Exclude kexec-tools for now
KEXEC_ENABLE = no

# Update this if the configuration mechanism changes from one release
# to the next.
ONIE_CONFIG_VERSION = 1

#-------------------------------------------------------------------------------
#
# Local Variables:
# mode: makefile-gmake
# End:

