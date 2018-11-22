# QEMU RISCV64 Virtual Machine

#  Copyright (C) 2018 Curt Brune <curt@brune.net>

ONIE_ARCH ?= riscv64

VENDOR_REV ?= 0

# Translate hardware revision to ONIE hardware revision
ifeq ($(VENDOR_REV),0)
  MACHINE_REV = 0
else
  $(warning Unknown VENDOR_REV '$(VENDOR_REV)' for MACHINE '$(MACHINE)')
  $(error Unknown VENDOR_REV)
endif

LINUX_VERSION = 4.19
LINUX_MINOR_VERSION = 3

# The SWITCH_ASIC_VENDOR is used to further differentiate the platform
# in the ONIE waterfall.  This string should be the stock ticker
# symbol of the ASIC vendor, in lower case.  The value in this example
# here is completely fictitious.
SWITCH_ASIC_VENDOR = qemu

# The VENDOR_VERSION string is appended to the overal ONIE version
# string.  HW vendors can use this to appended their own versioning
# information to the base ONIE version string.
# VENDOR_VERSION = .12.34

# Vendor ID -- IANA Private Enterprise Number:
# http://www.iana.org/assignments/enterprise-numbers
# Open Compute Project IANA number
VENDOR_ID = 42623

# Skip the i2ctools and the onie-syseeprom command for this platform
I2CTOOLS_ENABLE = no

# Disable UEFI support
UEFI_ENABLE = no

# Disable building firmware updates
FIRMWARE_UPDATE_ENABLE = no

# Do not modify Ethernet management MACs programmed by hypervisor.
SKIP_ETHMGMT_MACS = yes

# Disable building of secure boot binaries
SECURE_BOOT_ENABLE = no

# Console parameters can be defined here (default values are in
# build-config/arch/x86_64.make).
# For example,
# 
# CONSOLE_SPEED = 9600
# CONSOLE_DEV = 0

# Specify any extra parameters that you'd want to pass to the onie linux
# kernel command line in EXTRA_CMDLINE_LINUX env variable. Eg:
#
#EXTRA_CMDLINE_LINUX ?= install_url=http://server/path/to/installer debug earlyprintk=serial
#
# NOTE: You can give multiple space separated parameters

# Specify the default menu option when booting a recovery image.  Valid
# values are "rescue" or "embed" (without double-quotes). This
# parameter defaults to "rescue" mode if not specified here.
# RECOVERY_DEFAULT_ENTRY = embed

#-------------------------------------------------------------------------------
#
# Local Variables:
# mode: makefile-gmake
# End:
