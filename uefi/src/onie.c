#include "onie-uefi.h"

static CHAR16* build_info_var[] = {
	L"BUILD_VERSION",
	L"BUILD_DATE",
	L"BUILD_PLATFORM",
	L"BUILD_VENDOR_ID",
	L"BUILD_SWITCH_ASIC",
};

static CHAR16* build_info_val[] = {
	ONIE_UEFI_BUILD_VERSION,
	ONIE_UEFI_BUILD_DATE,
	ONIE_UEFI_BUILD_PLATFORM,
	ONIE_UEFI_BUILD_VENDOR_ID,
	ONIE_UEFI_BUILD_SWITCH_ASIC,
};

static void print_build_info() {
	UINTN i, j;
	UINTN width = 20;

	Print(L"ONIE UEFI Information:\n");
	for (i = 0; i < ARRAY_SIZE(build_info_var); i++) {
		/* Left justify variable name.  Brain dead gnu-efi
		 * Print() function does not interpret "%-20s"
		 * correctly....
		 */
		Print(L"  %s", build_info_var[i]);
		for (j = 0; j < (width - StrLen(build_info_var[i])); j++)
			Output(L" ");
		Print(L": %s\n", build_info_val[i]);
	}
}

EFI_STATUS
efi_main (EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {

	InitializeLib(ImageHandle, SystemTable);
	print_build_info();
	return EFI_SUCCESS;
}
