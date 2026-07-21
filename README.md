
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

**OpenCore 1.0.7**（2025年3月20日发布）

## macOS 兼容性

- macOS Sequoia（已测试）

## SMBIOS

`Macmini8,1`，配合 `CustomSMBIOSGuid=true` + `revpatch=sbvmm`

## 关键配置

### 核显 (DeviceProperties)

- `ig-platform-id`：`0x3E920000`（UHD 630，含帧缓冲补丁）
- 3 个 HDMI 帧缓冲端口映射（con0/con1/con2，connector type=0x0008）
- `igfxagdc=0`（禁用 AGDC 电源管理）
- `igfxonln=1`（强制在线显示）
- EDID 注入（`AAPL00,override-no-connect`）**对无显示器启动无效**（问题在 UEFI GOP 阶段，iGPU 检测不到显示设备就不初始化，EDID 注入来不及生效）

### 无显示器启动

如需无显示器启动（远程控制场景），**必须使用物理 HDMI 欺骗器**。欺骗器让 GOP 在开机自检时检测到"有显示器"，iGPU 才会正常初始化。启动完成后，有无显示器都无所谓。

### 启动参数

```
keepsyms=1 debug=0x100 rtcfx_exclude=80-AB darkwake=2 igfxonln=1 igfxagdc=0 e1000=1 -lilubetaall amfi=0x80
```

> 注：`amfi=0x80` 于 2026-07-21 添加，配合 AMFIPass.kext 在 SIP 0x0803 下放宽 AMFI 限制，保障 OpenCore kext 注入。参考 5T33Z0/OCLP4Hackintosh WiFi_Sonoma 指南。

### SIP 配置

`csr-active-config = 0x0803`（部分启用 SIP）

```
0x0803 = CSR_ALLOW_UNTRUSTED_KEXTS
       | CSR_ALLOW_UNRESTRICTED_FS
       | CSR_ALLOW_EXECUTABLE_POLICY_OVERRIDE
```

启用的保护：NVRAM Protections、BaseSystem Verification、Debugging Restrictions、DTrace Restrictions
禁用的保护：Kext Signing、Filesystem Protections（为 OCLP Root Patch 和 kext 注入保留）

> **演变历史**：最初使用 `0x0FFF`（全禁用），后发现全禁用导致钥匙串完整性失效，影响 AirDrop（详见下方 AirDrop 章节）。2026-07-21 改为 `0x0803`。

### AirDrop 状态

**当前状态：部分工作（单向）**

- iPad/Mac 互相能发现对方（BLE 广播成功）
- 手机/iPad → Mac 方向的 AirDrop 可以工作
- Mac → 手机/iPad 方向找不到设备（不完整）

**根因分析**：

完整因果链（通过 bluetoothd/securityd 日志确认）：
```
SIP 禁用 CSR_ALLOW_UNRESTRICTED_FS（Filesystem Protections: disabled）
    ↓
securityd: "found a non-proper sample, skipping..."（钥匙串完整性校验失败）
    ↓
bluetoothd: "Cloud master IRK and address are not available in storage"
    ↓
bluetoothd: "Cannot generate current user's RRA when the IRK is set to 0's" (STATUS 103)
    ↓
本地 IRK 全零 → 无法生成 RRA（Resolvable Random Address）
    ↓
AirDrop 双向发现不完整（能被发现，但不能主动发现其他设备）
```

**关键证据**：
- `bluetoothd` 能读取其他设备的 IRK（`Read IRK for device ... : result 150`）
- 但自己的 `Cloud master IRK` 从钥匙串取不到（`non-proper sample`）
- BLE 广播本身成功（`Started advertising successfully status=0`）
- AWDL Enabled: No（数据传输层不工作）

**为什么这是黑苹果架构限制**：
- OCLP Root Patch 需要禁用 Filesystem Protections（注入 IO80211FamilyLegacy 等 kext）
- AirDrop 完整 IRK 机制需要完整的文件系统保护（保护钥匙串完整性）
- 两者 contradictory：0x0803 已是最佳平衡点（比 0x0FFF 改善了 BLE 广播和发现）

**已排除的方案**：
- `0x0000`（完全启用 SIP）：Root Patch 完全失效，Wi-Fi 不可用
- BlueToolFixup + BrcmPatchRAM3：仅对非原生卡有效，本机 BCM94360Z4 是原生 Apple 兼容卡（Vendor ID: 0x004C），蓝牙固件已正常加载（v150 c9318），加装反而与 OCLP Root Patch 冲突
- 重建钥匙串 + 重登 iCloud：钥匙串条目完整性问题是架构限制，非条目损坏

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
| UTBMap | 1.1 | HP 600 G4 SFF USB 端口映射（含 HS11/HS14 内部端口） |
| RestrictEvents | - | 限制事件补丁 |

### WiFi/蓝牙

BCM94360Z4 是 Apple 原生兼容网卡，**不需要**以下 kext（EFI 中绝对不存在）：
- AirportBrcmFixup
- BluetoothFixup
- BlueToolFixup
- BrcmFirmwareData
- BrcmPatchRAM3

WiFi 通过 `IO80211FamilyLegacy + AirPort_BrcmNIC` 原生驱动，配合 OCLP-Mod 2.6.9 Root Patch（注意：3.x 版本在 Sequoia 上不稳定，务必使用 2.6.9）。

蓝牙通过 UTBMap 的 **HS11（port 11）和 HS14（port 14）内部端口映射**工作。BCM94360Z4 的蓝牙通过 USB 接口连接到主板 XHCI 控制器的内部端口，UTBMap 将这些端口标记为 `UsbConnector=255`（内部设备），macOS 才能枚举蓝牙设备。蓝牙使用 **USB transport**（非 UART），Address 和固件版本均正常。

> **重要**：之前尝试过 SSDT-BT（通过 UBTC ACPI 注入 _DSM）三次均失败——UBTC 实际是 USB Type-C UCSI 控制器（`_HID=USBC000`），不是蓝牙设备，且已有 _DSM 方法。蓝牙的正确修复方式是 UTBMap 端口映射，不是 SSDT 注入。

### 已禁用的 Kext（本机无对应硬件）

itlwm、AirPortUtility、IntelBluetoothFirmware、IntelBTPatcher、BluetoothFileExchange、FeatureUnlock

### ACPI 补丁（13 个 SSDT）

SSDT-TPM-Off、SSDT-AWAC-HPET-RTC、SSDT-PLUG、SSDT-PMCR、SSDT-PPMC、SSDT-MCHC、SSDT-XOSI、SSDT-XSPI、SSDT-DMAC、SSDT-USBX、SSDT-EC、SSDT-WAK、SSDT-PTS

> 注：SSDT-BT 已移除（蓝牙通过 UTBMap 端口映射修复，不需要 ACPI 注入）。

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
- Intel UHD 630 显示输出（HDMI）
- Intel I219 有线网卡
- WiFi（BCM94360Z4 原生驱动 + OCLP-Mod 2.6.9）
- 蓝牙（BCM94360Z4，UTBMap HS11/HS14 内部端口映射，USB transport，Address/Firmware 正常）
- USB 端口（UTBMap 定制映射，含内部蓝牙端口）
- CPU 电源管理

## 待完善

- 声卡（可能需要调整 layout-id）
- iCloud / iMessage（需生成唯一 SMBIOS 序列号）
- 无显示器启动（需物理 HDMI 欺骗器，已购买待测试）

## 注意事项

1. **SMBIOS 序列号**：配置中的序列号为占位符，使用 iCloud/iMessage 前必须用 [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) 为 Macmini8,1 生成你自己的序列号。

2. **无显示器启动**：EDID 注入（`AAPL00,override-no-connect`）对无显示器启动**无效**。问题在 UEFI GOP 阶段而非 macOS，iGPU 必须在开机自检时检测到显示设备才初始化。解决方案是使用物理 HDMI 欺骗器（插入 HDMI 口），让 GOP 认为"有显示器"。启动完成后拔掉欺骗器也不影响使用。

3. **显示输出端口**：本机背面有 2 个 DP 口。当前帧缓冲补丁将 3 个 connector 全设为 HDMI（type=0x0008），busid 分别为 1/2/4。如果只有一个口有信号，需调整 framebuffer busid 值。

4. **OCLP-Mod 版本**：BCM WiFi Root Patch 务必使用 **OCLP-Mod 2.6.9**。3.x 版本在 Sequoia 上存在签名稳定性问题。

5. **蓝牙端口**：BCM94360Z4 的蓝牙使用 XHCI 内部端口 HS11。如果更换 WiFi 卡或其他硬件导致蓝牙端口变化，需重新调整 UTBMap 中对应的端口映射。

6. **调试日志**：OpenCore 日志保存在 macOS 分区的 `/var/log/OpenCore.log`。

7. **从 U 盘迁移到硬盘**：复制 EFI 到硬盘 EFI 分区后，需在 BIOS 中将硬盘启动项设为第一优先级。确保复制完整，特别是 `.kext/Contents/MacOS/` 下的可执行文件不能遗漏。

## 致谢

- [Acidanthera](https://github.com/acidanthera) - OpenCore、Lilu、VirtualSMC、WhateverGreen、AppleALC 等
- [Mieze](https://github.com/Mieze) - IntelMausiEthernet
- [Dortania](https://dortania.github.io) - OpenCore 安装指南

---

# HP ProDesk 600 G4 SFF - OpenCore EFI (English)

OpenCore EFI for **HP ProDesk 600 G4 SFF** with **Intel Core i5-9500T**, running macOS Sequoia.

---

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

**OpenCore 1.0.7** (released March 20, 2025)

## macOS Compatibility

- macOS Sequoia (tested)

## SMBIOS

`Macmini8,1` with `CustomSMBIOSGuid=true` + `revpatch=sbvmm`

## Key Configuration

### DeviceProperties (iGPU)

- `ig-platform-id`: `0x3E920000` (UHD 630 with framebuffer patches)
- 3x HDMI framebuffer mapping (con0/con1/con2, connector type=0x0008)
- `igfxagdc=0` (disable AGDC power management)
- `igfxonln=1` (force display online)
- EDID injection (`AAPL00,override-no-connect`) **does NOT work for headless boot** — the issue is at the UEFI GOP phase, where iGPU won't initialize without detecting a display device. EDID injection cannot take effect before GOP.

### Headless Boot

If you need to boot without a display (e.g., for remote control), you **must use a physical HDMI dummy plug**. The dummy plug makes GOP detect "a display is present" during POST, allowing iGPU initialization. Once boot completes, having no display connected is fine.

### Boot Arguments

```
keepsyms=1 debug=0x100 rtcfx_exclude=80-AB darkwake=2 igfxonln=1 igfxagdc=0 e1000=1 -lilubetaall amfi=0x80
```

> Note: `amfi=0x80` added 2026-07-21 to relax AMFI alongside AMFIPass.kext under SIP 0x0803, ensuring OpenCore kext injection. Per 5T33Z0/OCLP4Hackintosh WiFi_Sonoma guide.

### SIP Configuration

`csr-active-config = 0x0803` (partial SIP)

```
0x0803 = CSR_ALLOW_UNTRUSTED_KEXTS
       | CSR_ALLOW_UNRESTRICTED_FS
       | CSR_ALLOW_EXECUTABLE_POLICY_OVERRIDE
```

Protected: NVRAM Protections, BaseSystem Verification, Debugging Restrictions, DTrace Restrictions
Unprotected: Kext Signing, Filesystem Protections (for OCLP Root Patch and kext injection)

> **History**: Originally `0x0FFF` (fully disabled), changed to `0x0803` on 2026-07-21 after discovering full disable broke keychain integrity and AirDrop (see AirDrop section below).

### AirDrop Status

**Current: Partial (one-way)**

- iPad and Mac can discover each other (BLE advertising works)
- Phone/iPad → Mac AirDrop works
- Mac → Phone/iPad cannot find devices (incomplete)

**Root Cause** (confirmed via bluetoothd/securityd logs):
```
SIP disables CSR_ALLOW_UNRESTRICTED_FS (Filesystem Protections: disabled)
    ↓
securityd: "found a non-proper sample, skipping..." (keychain integrity check fails)
    ↓
bluetoothd: "Cloud master IRK and address are not available in storage"
    ↓
bluetoothd: "Cannot generate current user's RRA when the IRK is set to 0's" (STATUS 103)
    ↓
Local IRK all zeros → cannot generate RRA (Resolvable Random Address)
    ↓
AirDrop bidirectional discovery incomplete
```

**Why this is a Hackintosh architectural limitation**:
- OCLP Root Patch requires disabling Filesystem Protections (to inject IO80211FamilyLegacy etc.)
- AirDrop's full IRK mechanism requires complete filesystem protection (keychain integrity)
- These are contradictory; 0x0803 is the best balance (improved BLE advertising vs 0x0FFF)

**Excluded solutions**:
- `0x0000` (full SIP): Root Patch fails completely, Wi-Fi unusable
- BlueToolFixup + BrcmPatchRAM3: only for non-native cards; BCM94360Z4 is native Apple-compatible (Vendor ID: 0x004C), firmware already loaded (v150 c9318), adding these conflicts with OCLP Root Patch
- Keychain rebuild + iCloud re-login: integrity issue is architectural, not corruption

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
| UTBMap | 1.1 | HP 600 G4 SFF USB port map (includes HS11/HS14 internal ports) |
| RestrictEvents | - | Restrict events patch |

### WiFi/Bluetooth

BCM94360Z4 is a native Apple-compatible card. The following kexts are **NOT** needed (absent from EFI):
- AirportBrcmFixup
- BluetoothFixup
- BlueToolFixup
- BrcmFirmwareData
- BrcmPatchRAM3

WiFi uses `IO80211FamilyLegacy + AirPort_BrcmNIC` native driver with OCLP-Mod 2.6.9 Root Patch (note: 3.x versions are unstable on Sequoia, use 2.6.9 only).

Bluetooth works via UTBMap's **HS11 (port 11) and HS14 (port 14) internal port mapping**. BCM94360Z4's Bluetooth connects via USB to the XHCI controller's internal ports. UTBMap marks these as `UsbConnector=255` (internal device), allowing macOS to enumerate the Bluetooth device. Bluetooth uses **USB transport** (not UART), with normal Address and firmware version.

> **Important**: Previous attempts using SSDT-BT (injecting _DSM via UBTC ACPI) failed three times — UBTC is actually a USB Type-C UCSI controller (`_HID=USBC000`), not a Bluetooth device, and already has its own _DSM method. The correct fix is UTBMap port mapping, not SSDT injection.

### Disabled Kexts (no hardware)

itlwm, AirPortUtility, IntelBluetoothFirmware, IntelBTPatcher, BluetoothFileExchange, FeatureUnlock

### ACPI (13 SSDTs)

SSDT-TPM-Off, SSDT-AWAC-HPET-RTC, SSDT-PLUG, SSDT-PMCR, SSDT-PPMC, SSDT-MCHC, SSDT-XOSI, SSDT-XSPI, SSDT-DMAC, SSDT-USBX, SSDT-EC, SSDT-WAK, SSDT-PTS

> Note: SSDT-BT has been removed (Bluetooth is fixed via UTBMap port mapping, no ACPI injection needed).

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
- Intel UHD 630 display output (HDMI)
- Intel I219 Ethernet
- WiFi (BCM94360Z4 native driver + OCLP-Mod 2.6.9)
- Bluetooth (BCM94360Z4, UTBMap HS11/HS14 internal port mapping, USB transport, Address/Firmware normal)
- USB ports (UTBMap custom mapping, including internal Bluetooth ports)
- CPU power management

## What Needs Work

- Audio (may need layout-id adjustment)
- iCloud / iMessage (need to generate unique SMBIOS serials with GenSMBIOS)
- Headless boot (requires physical HDMI dummy plug — purchased, pending testing)

## Important Notes

1. **SMBIOS Serials**: The serials in this config are placeholder values. You MUST generate your own using [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) for Macmini8,1 before using iCloud/iMessage.

2. **Headless Boot**: EDID injection (`AAPL00,override-no-connect`) does NOT work for headless boot. The issue is at the UEFI GOP phase, not macOS. iGPU must detect a display device during POST to initialize. The solution is a physical HDMI dummy plug (inserted into HDMI port) — once boot completes, removing the dummy plug doesn't affect usage.

3. **Display Output**: This machine has 2x DisplayPort on rear. The framebuffer patch maps 3 HDMI connectors (type=0x0008) with busid 1/2/4. If only one port has signal, adjust the framebuffer busid values.

4. **OCLP-Mod Version**: BCM WiFi Root Patch must use **OCLP-Mod 2.6.9**. Version 3.x has signature stability issues on Sequoia.

5. **Bluetooth Port**: BCM94360Z4's Bluetooth uses XHCI internal port HS11. If you change the WiFi card or other hardware that shifts the Bluetooth port, you must update the corresponding UTBMap port mapping.

6. **Debug Log**: OpenCore logs are saved to `/var/log/OpenCore.log` on the macOS partition for troubleshooting.

7. **Migrating from USB to HDD**: After copying EFI to the hard disk EFI partition, set the hard disk boot entry as first priority in BIOS. Ensure the copy is complete, especially the executable files under `.kext/Contents/MacOS/`.

## Credits

- [Acidanthera](https://github.com/acidanthera) - OpenCore, Lilu, VirtualSMC, WhateverGreen, AppleALC, and more
- [Mieze](https://github.com/Mieze) - IntelMausiEthernet
- [Dortania](https://dortania.github.io) - OpenCore Install Guide
