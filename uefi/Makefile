#-------------------------------------------------------------------------------
#
#  Copyright (C) 2016 Curt Brune <curt@cumulusnetworks.com>
#
#  SPDX-License-Identifier:     GPL-2.0
#
#-------------------------------------------------------------------------------

CC		= $(CROSS_COMPILE)gcc
LD		= $(CROSS_COMPILE)ld
OBJCOPY		= $(CROSS_COMPILE)objcopy

ARCH		= $(shell $(CC) -dumpmachine | cut -f1 -d- | sed s,i[3456789]86,ia32,)
OBJCOPY_GTE224  = $(shell expr `$(OBJCOPY) --version |grep ^"GNU objcopy" | sed 's/^.* //g' | cut -f1-2 -d.` \>= 2.24)

EFI_INCLUDE	:= /usr/include/efi
EFI_INCLUDES	= -nostdinc -I$(EFI_INCLUDE) -I$(EFI_INCLUDE)/$(ARCH) -I$(EFI_INCLUDE)/protocol -I$(shell pwd)/include
EFI_PATH	:= /usr/lib64/gnuefi

LIB_PATH	= /usr/lib64

LIB_GCC		= $(shell $(CC) -print-libgcc-file-name)
EFI_LIBS	= -lefi -lgnuefi $(LIB_GCC) 

EFI_CRT_OBJS 	= $(EFI_PATH)/crt0-efi-$(ARCH).o
EFI_LDS         = $(EFI_PATH)/elf_$(ARCH)_efi.lds

OUTPUT_DIR	= .

# Seed compiler and linker flags with the ONIE build environment flags
CFLAGS		= $(ONIE_CFLAGS)
LDFLAGS		= $(ONIE_LDFLAGS)

CFLAGS		+= -ggdb -O0 -fno-stack-protector -fno-strict-aliasing -fpic \
		  -fshort-wchar -Wall -Wsign-compare -Werror -fno-builtin \
		  -Werror=sign-compare -ffreestanding \
		  -I$(shell $(CC) -print-file-name=include) \
		  $(EFI_INCLUDES)

# Add ONIE build environment includes
ifneq ($(ONIE_UEFI_BUILD_INCLUDE),)
  CFLAGS	+= -I$(ONIE_UEFI_BUILD_INCLUDE)
endif

ifeq ($(ARCH),x86_64)
	CFLAGS	+= -mno-mmx -mno-sse -mno-red-zone -nostdinc \
		-maccumulate-outgoing-args \
		-DEFI_FUNCTION_WRAPPER -DGNU_EFI_USE_MS_ABI
endif

ifneq ($(origin VENDOR_CERT_FILE), undefined)
	CFLAGS += -DVENDOR_CERT_FILE=\"$(VENDOR_CERT_FILE)\"
endif
ifneq ($(origin VENDOR_DBX_FILE), undefined)
	CFLAGS += -DVENDOR_DBX_FILE=\"$(VENDOR_DBX_FILE)\"
endif

LDFLAGS		+= --hash-style=sysv -nostdlib -znocombreloc \
		-T $(EFI_LDS) -shared -Bsymbolic --build-id=sha1 \
		-L$(EFI_PATH) -L$(LIB_PATH) $(EFI_CRT_OBJS) 

shell_test	= $(strip $(shell $(1) && echo "true"))

# For signing purposes this build requires a shim build directory
ifeq ($(origin SHIM_DIR), undefined)
  $(error SHIM_DIR is not defined)
endif

SHIM_CERTDB	= $(SHIM_DIR)/certdb
ifneq ($(call shell_test,test -d $(SHIM_CERTDB)), true)
  $(error SHIM cert database does not exist: $(SHIM_DIR)/certdb)
endif

SRC_DIR		= src
INCLUDE_DIR	= include

APPS		= onie.efi onie.efi.signed
TARGETS		= $(foreach t, $(APPS), $(OUTPUT_DIR)/$(t))
SRC_FILES	= onie.c
SOURCES		= $(foreach t, $(SRC_FILES), $(SRC_DIR)/$(t))
OBJS		= $(foreach t, $(SRC_FILES:.c=.o),$(OUTPUT_DIR)/$(t))

all: $(TARGETS)

-include $(OUTPUT_DIR)/*.d

$(OUTPUT_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -MD -MT $@ -c -o $@ $<

$(OUTPUT_DIR)/onie.so: $(OBJS)
	$(LD) -o $@ $(LDFLAGS) $^ $(EFI_LIBS)

FORMAT		?= --target efi-app-$(ARCH)

%.efi: %.so
ifneq ($(OBJCOPY_GTE224),1)
	$(error objcopy >= 2.24 is required)
endif
	$(OBJCOPY) -j .text -j .sdata -j .data \
		-j .dynamic -j .dynsym  -j .rel* \
		-j .rela* -j .reloc -j .eh_frame \
		$(FORMAT)  $^ $@
	$(OBJCOPY) -j .text -j .sdata -j .data \
		-j .dynamic -j .dynsym  -j .rel* \
		-j .rela* -j .reloc -j .eh_frame \
		-j .debug_info -j .debug_abbrev -j .debug_aranges \
		-j .debug_line -j .debug_str -j .debug_ranges \
		-j .note.gnu.build-id \
		$(FORMAT) $^ $@.debug

%.efi.signed: %.efi
	pesign --certdir=$(SHIM_CERTDB) --certficate="shim" --sign --force \
		--in=$< --out=$@

clean:
	rm -f $(TARGET) $(OBJS)
	rm -f *.debug *.so *.efi *.tar.*

#-------------------------------------------------------------------------------
#
# Local Variables:
# mode: makefile-gmake
# End:
