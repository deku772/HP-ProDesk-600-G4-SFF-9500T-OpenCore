---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: '600637b5-6a61-4881-b900-30105f383443'
  PropagateID: '600637b5-6a61-4881-b900-30105f383443'
  ReservedCode1: '61d206e8-4176-44a5-86f7-5c6c3aa9645f'
  ReservedCode2: '61d206e8-4176-44a5-86f7-5c6c3aa9645f'
---

# HP ProDesk 600 G4 SFF - OpenCore EFI

OpenCore EFI for **HP ProDesk 600 G4 SFF** with **Intel Core i5-9500T**, running macOS Sequoia.

## Hardware Specs

| Component | Model |
|---|---|
| Model | HP ProDesk 600 G4 SFF |
| CPU | Intel Core i5-9500T (9th Gen, 35W) |
| iGPU | Intel UHD 630 |
| RAM | 16GB DDR4 2133MHz |
| Storage | 256GB NVMe SSD |
| Ethernet | Intel I219 |
| WiFi/Bluetooth | None |

## OpenCore Version

**OpenCore 1.0.7**

## macOS Compatibility

- macOS Sequoia (tested)

## SMBIOS

`Macmini8,1` with `CustomSMBIOSGuid=true` + `revpatch=sbvmm`

## Key Configuration

### DeviceProperties (iGPU)

- `ig-platform-id`: `0x3E920000` (UHD 630 with framebuffer patches)
- 3x DisplayPort framebuffer mapping (con0/con1/con2)
- `igfxagdc=0` (disable AGDC power management)

### Boot Arguments

```
keepsyms=1 debug=0x100 rtcfx_exclude=80-AB darkwake=2 igfxonln=1 igfxagdc=0 -v
```

### Enabled Kexts

| Kext | Version | Purpose |
|---|---|---|
| Lilu | 1.7.2 | Patch engine |
| VirtualSMC | 1.3.7 | SMC emulator |
| WhateverGreen | 1.7.0 | iGPU patches |
| IntelMausiEthernet | 3.0.0 | Intel I219 LAN |
| AppleALC | 1.9.7 | Audio |
| SMCProcessor | 1.3.7 | CPU temp monitoring |
| SMCSuperIO | 1.3.7 | Fan speed monitoring |
| NVMeFix | 1.1.3 | NVMe power management |
| RestrictEvents | 1.1.6 | System update fix |
| USBPorts | 1.0 | USB port mapping |

### Disabled Kexts (no hardware)

itlwm, AirPortUtility, BlueToolFixup, IntelBluetoothFirmware, IntelBTPatcher, BluetoothFileExchange, FeatureUnlock

### ACPI (13 SSDTs)

SSDT-TPM-Off, SSDT-AWAC-HPET-RTC, SSDT-PLUG, SSDT-PMCR, SSDT-PPMC, SSDT-MCHC, SSDT-XOSI, SSDT-XSPI, SSDT-DMAC, SSDT-USBX, SSDT-EC, SSDT-WAK, SSDT-PTS

### Booter Quirks

- `RebuildAppleMemoryMap=true`
- `SetupVirtualMap=true`
- `EnableWriteUnprotector=false`
- `DevirtualiseMmio=true`
- `ProtectUefiServices=true`
- `FixupAppleEfiImages=true`

### Kernel Quirks

- `AppleXcpmCfgLock=true`
- `CustomSMBIOSGuid=true`
- `DisableIoMapper=true`
- `DisableIoMapperMapping=true`
- `DisableLinkeditJettison=true`
- `DisableRtcChecksum=true`
- `LapicKernelPanic=true`

### UEFI Drivers

- OpenHfsPlus.efi
- OpenRuntime.efi
- OpenCanopy.efi (GUI picker)
- OpenUsbKbDxe.efi (USB keyboard support)
- ResetNvramEntry.efi

## What Works

- macOS Sequoia boot and installation
- Intel UHD 630 display output (DisplayPort)
- Intel I219 Ethernet
- USB ports (partial, needs custom mapping)
- Audio (may need layout-id adjustment)
- CPU power management

## What Needs Work

- USB port mapping (currently using HP 400 G5 Mini mapping, needs USBToolBox rebuild for 600 G4 SFF)
- Audio layout-id (currently 23, may need adjustment for ALC codec)
- iCloud / iMessage (need to generate unique SMBIOS serials with GenSMBIOS)

## Important Notes

1. **SMBIOS Serials**: The serials in this config are placeholder values. You MUST generate your own using [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) for Macmini8,1 before using iCloud/iMessage.

2. **USB Mapping**: Use [USBToolBox](https://github.com/USBToolBox/tool) under macOS to create a proper port map for your specific machine, then replace `USBPorts.kext`.

3. **DisplayPorts**: This machine has 2x DisplayPort on rear. The framebuffer patch maps 3 DP connectors. If you only get signal on one port, adjust the framebuffer busid values.

4. **Debug Log**: OpenCore logs are saved to `/var/log/OpenCore.log` on the macOS partition for troubleshooting.

## Credits

- [Acidanthera](https://github.com/acidanthera) - OpenCore, Lilu, VirtualSMC, WhateverGreen, AppleALC, and more
- [OpenIntelWireless](https://github.com/OpenIntelWireless) - itlwm
- [Mieze](https://github.com/Mieze) - IntelMausiEthernet
- [Dortania](https://dortania.github.io) - OpenCore Install Guide