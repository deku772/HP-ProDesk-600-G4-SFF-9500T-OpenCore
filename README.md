---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: '19ca4c08-9bcd-47f4-8e98-4e779d004427'
  PropagateID: '19ca4c08-9bcd-47f4-8e98-4e779d004427'
  ReservedCode1: '0ae13d64-94b6-4719-b350-256334ba19ce'
  ReservedCode2: '0ae13d64-94b6-4719-b350-256334ba19ce'
---

# HP ProDesk 600 G4 SFF - OpenCore EFI

适用于 **惠普 ProDesk 600 G4 SFF**（i5-9500T）的 OpenCore EFI，运行 macOS Sequoia。

---

## 硬件配置

| 硬件 | 型号 |
|---|---|
| 机型 | 惠普 ProDesk 600 G4 SFF |
| CPU | Intel Core i5-9500T（9代，35W） |
| 核显 | Intel UHD 630 |
| 内存 | 16GB DDR4 2133MHz |
| 硬盘 | 256GB NVMe SSD |
| 网卡 | Intel I219（有线） |
| WiFi/蓝牙 | 无 |

## OpenCore 版本

**OpenCore 1.0.7**

## macOS 兼容性

- macOS Sequoia（已测试）

## SMBIOS

`Macmini8,1`，配合 `CustomSMBIOSGuid=true` + `revpatch=sbvmm`

## 关键配置

### 核显 (DeviceProperties)

- `ig-platform-id`：`0x3E920000`（UHD 630，含帧缓冲补丁）
- 3 个 DisplayPort 帧缓冲端口映射（con0/con1/con2）
- `igfxagdc=0`（禁用 AGDC 电源管理）

### 启动参数

```
keepsyms=1 debug=0x100 rtcfx_exclude=80-AB darkwake=2 igfxonln=1 igfxagdc=0 -v
```

### 启用的 Kext

| Kext | 版本 | 用途 |
|---|---|---|
| Lilu | 1.7.2 | 补丁引擎 |
| VirtualSMC | 1.3.7 | SMC 仿真 |
| WhateverGreen | 1.7.0 | 核显补丁 |
| IntelMausiEthernet | 3.0.0 | Intel I219 有线网卡 |
| AppleALC | 1.9.7 | 声卡驱动 |
| SMCProcessor | 1.3.7 | CPU 温度监控 |
| SMCSuperIO | 1.3.7 | 风扇转速监控 |
| NVMeFix | 1.1.3 | NVMe 电源管理 |
| RestrictEvents | 1.1.6 | 系统更新修正 |
| USBPorts | 1.0 | USB 端口映射 |

### 已禁用的 Kext（本机无对应硬件）

itlwm、AirPortUtility、BlueToolFixup、IntelBluetoothFirmware、IntelBTPatcher、BluetoothFileExchange、FeatureUnlock

### ACPI 补丁（13 个 SSDT）

SSDT-TPM-Off、SSDT-AWAC-HPET-RTC、SSDT-PLUG、SSDT-PMCR、SSDT-PPMC、SSDT-MCHC、SSDT-XOSI、SSDT-XSPI、SSDT-DMAC、SSDT-USBX、SSDT-EC、SSDT-WAK、SSDT-PTS

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

### UEFI 驱动

- OpenHfsPlus.efi
- OpenRuntime.efi
- OpenCanopy.efi（图形化启动选择器）
- OpenUsbKbDxe.efi（USB 键盘支持，HP OEM 主板必需）
- ResetNvramEntry.efi

## 正常工作的功能

- macOS Sequoia 启动和安装
- Intel UHD 630 显示输出（DisplayPort）
- Intel I219 有线网卡
- USB 端口（部分可用，需定制映射）
- 声卡（可能需要调整 layout-id）
- CPU 电源管理

## 待完善

- **USB 端口映射**：当前使用的是 HP 400 G5 Mini 的映射文件，需要用 USBToolBox 在本机上重新生成
- **声卡 layout-id**：当前设为 23，可能需要根据实际 ALC 编解码器调整
- **iCloud / iMessage**：需要用 GenSMBIOS 为 Macmini8,1 生成唯一的序列号

## 注意事项

1. **SMBIOS 序列号**：配置中的序列号为占位符，使用 iCloud/iMessage 前必须用 [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) 为 Macmini8,1 生成你自己的序列号。

2. **USB 映射**：在 macOS 下使用 [USBToolBox](https://github.com/USBToolBox/tool) 生成本机专属端口映射，替换 `USBPorts.kext`。

3. **DisplayPort 端口**：本机背面有 2 个 DP 口。当前帧缓冲补丁映射了 3 个 DP 连接器。如果只有一个口有信号，需调整 framebuffer busid 值。

4. **调试日志**：OpenCore 日志保存在 macOS 分区的 `/var/log/OpenCore.log`。

5. **从 U 盘迁移到硬盘**：复制 EFI 到硬盘 EFI 分区后，需在 BIOS 中将硬盘启动项设为第一优先级。确保复制完整，特别是 `.kext/Contents/MacOS/` 下的可执行文件不能遗漏。

## 致谢

- [Acidanthera](https://github.com/acidanthera) - OpenCore、Lilu、VirtualSMC、WhateverGreen、AppleALC 等
- [Mieze](https://github.com/Mieze) - IntelMausiEthernet
- [Dortania](https://dortania.github.io) - OpenCore 安装指南

---

# HP ProDesk 600 G4 SFF - OpenCore EFI (English)

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
- OpenUsbKbDxe.efi (USB keyboard support, required for HP OEM)
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

2. **USB Mapping**: Use [USBToolBox](https://github.com/USBToolBox/tool) under macOS to create a proper port map, then replace `USBPorts.kext`.

3. **DisplayPorts**: This machine has 2x DisplayPort on rear. The framebuffer patch maps 3 DP connectors. If you only get signal on one port, adjust the framebuffer busid values.

4. **Debug Log**: OpenCore logs are saved to `/var/log/OpenCore.log` on the macOS partition for troubleshooting.

5. **Migrating from USB to HDD**: After copying EFI to the hard disk EFI partition, set the hard disk boot entry as first priority in BIOS. Ensure the copy is complete, especially the executable files under `.kext/Contents/MacOS/`.

## Credits

- [Acidanthera](https://github.com/acidanthera) - OpenCore, Lilu, VirtualSMC, WhateverGreen, AppleALC, and more
- [Mieze](https://github.com/Mieze) - IntelMausiEthernet
- [Dortania](https://dortania.github.io) - OpenCore Install Guide