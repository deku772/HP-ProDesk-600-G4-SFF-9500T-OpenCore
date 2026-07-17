
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
| WiFi/蓝牙 | BCM94360Z4（原生 Apple 兼容，WiFi+BT 二合一） |

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
| AMFIPass | 1.4.1 | 绕过 AMFI 安全策略 |
| IOSkywalkFamily | 1.0 | WiFi Skywalk 框架 |
| IO80211FamilyLegacy | 1200.12.2b1 | WiFi 遗产驱动框架 |
| AirPortBrcmNIC | 1400.1.1 | BCM WiFi 原生驱动 |
| USBToolBox | 1.1.1 | USB 端口映射工具 |
| UTBMap | 1.1 | HP 600 G4 SFF USB 端口映射 |
| RestrictEvents | - | 限制事件补丁 |

### WiFi/蓝牙

BCM94360Z4 是 Apple 原生兼容网卡，**不需要**以下 kext（EFI 中绝对不存在）：
- AirportBrcmFixup
- BluetoothFixup
- BlueToolFixup
- BrcmFirmwareData
- BrcmPatchRAM3

WiFi 通过 `IO80211FamilyLegacy + AirPort_BrcmNIC` 原生驱动，配合 OCLP-Mod 2.6.9 Root Patch。
蓝牙通过 `UBTC ACPI + SSDT-BT` 注入电源状态，使用原生 UART transport。

### 已禁用的 Kext（本机无对应硬件）

itlwm、AirPortUtility、IntelBluetoothFirmware、IntelBTPatcher、BluetoothFileExchange、FeatureUnlock

### ACPI 补丁（14 个 SSDT）

SSDT-TPM-Off、SSDT-AWAC-HPET-RTC、SSDT-PLUG、SSDT-PMCR、SSDT-PPMC、SSDT-MCHC、SSDT-XOSI、SSDT-XSPI、SSDT-DMAC、SSDT-USBX、SSDT-EC、SSDT-WAK、SSDT-PTS、**SSDT-BT**（蓝牙电源状态注入）

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
- WiFi（BCM94360Z4 原生驱动 + OCLP-Mod 2.6.9）
- USB 端口（UTBMap 定制映射）
- CPU 电源管理

## 待完善

- 蓝牙（BCM94360Z4 原生芯片，IOBluetoothHCIController 已连接，Address=NULL 需排查固件上传）
- 声卡（可能需要调整 layout-id）
- iCloud / iMessage（需生成唯一 SMBIOS 序列号）

## 注意事项

1. **SMBIOS 序列号**：配置中的序列号为占位符，使用 iCloud/iMessage 前必须用 [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) 为 Macmini8,1 生成你自己的序列号。


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
| WiFi/Bluetooth | BCM94360Z4 (Native Apple-compatible WiFi+BT) |

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
| AMFIPass | 1.4.1 | Bypass AMFI security policy |
| IOSkywalkFamily | 1.0 | WiFi Skywalk framework |
| IO80211FamilyLegacy | 1200.12.2b1 | WiFi legacy driver framework |
| AirPortBrcmNIC | 1400.1.1 | BCM WiFi native driver |
| USBToolBox | 1.1.1 | USB port mapping tool |
| UTBMap | 1.1 | HP 600 G4 SFF USB port map |
| RestrictEvents | - | Restrict events patch |

### WiFi/Bluetooth

BCM94360Z4 is a native Apple-compatible card. The following kexts are **NOT** needed (absent from EFI):
- AirportBrcmFixup
- BluetoothFixup
- BlueToolFixup
- BrcmFirmwareData
- BrcmPatchRAM3

WiFi uses `IO80211FamilyLegacy + AirPort_BrcmNIC` native driver with OCLP-Mod 2.6.9 Root Patch.
Bluetooth uses `UBTC ACPI + SSDT-BT` power-state injection with native UART transport.

### Disabled Kexts (no hardware)

itlwm, AirPortUtility, IntelBluetoothFirmware, IntelBTPatcher, BluetoothFileExchange, FeatureUnlock

### ACPI (14 SSDTs)

SSDT-TPM-Off, SSDT-AWAC-HPET-RTC, SSDT-PLUG, SSDT-PMCR, SSDT-PPMC, SSDT-MCHC, SSDT-XOSI, SSDT-XSPI, SSDT-DMAC, SSDT-USBX, SSDT-EC, SSDT-WAK, SSDT-PTS, **SSDT-BT** (Bluetooth power-state injection)

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
- WiFi (BCM94360Z4 native driver + OCLP-Mod 2.6.9)
- USB ports (UTBMap custom mapping)
- CPU power management

## What Needs Work

- Bluetooth (BCM94360Z4 native chip, IOBluetoothHCIController connected, Address=NULL - firmware upload needs debugging)
- Audio (may need layout-id adjustment)
- iCloud / iMessage (need to generate unique SMBIOS serials with GenSMBIOS)

## Important Notes

1. **SMBIOS Serials**: The serials in this config are placeholder values. You MUST generate your own using [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) for Macmini8,1 before using iCloud/iMessage.


3. **DisplayPorts**: This machine has 2x DisplayPort on rear. The framebuffer patch maps 3 DP connectors. If you only get signal on one port, adjust the framebuffer busid values.

4. **Debug Log**: OpenCore logs are saved to `/var/log/OpenCore.log` on the macOS partition for troubleshooting.

5. **Migrating from USB to HDD**: After copying EFI to the hard disk EFI partition, set the hard disk boot entry as first priority in BIOS. Ensure the copy is complete, especially the executable files under `.kext/Contents/MacOS/`.

## Credits

- [Acidanthera](https://github.com/acidanthera) - OpenCore, Lilu, VirtualSMC, WhateverGreen, AppleALC, and more
- [Mieze](https://github.com/Mieze) - IntelMausiEthernet
- [Dortania](https://dortania.github.io) - OpenCore Install Guide