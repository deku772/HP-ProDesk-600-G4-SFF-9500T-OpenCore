---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: 'd4ace08c-ac1c-4603-a9c2-d7a01e15dd28'
  PropagateID: 'd4ace08c-ac1c-4603-a9c2-d7a01e15dd28'
  ReservedCode1: 'ed55d836-d2b5-43df-9f8c-a8a199015af8'
  ReservedCode2: 'ed55d836-d2b5-43df-9f8c-a8a199015af8'
---

# HP ProDesk 600 G4 SFF - OpenCore EFI

适用于 **惠普 ProDesk 600 G4 SFF**（i5-9500T）的 OpenCore EFI，**跨 macOS 版本通用**（Ventura 13 / Sequoia 15 / Tahoe 26），当前运行 macOS Sequoia 15.7.8。

> **跨版本兼容**：通过 OCLP kext 的 `MinKernel=23.0.0` 门禁，同一份 EFI 可在 macOS 13-26 上启动——Ventura 13 使用系统原生 WiFi 免驱，Sequoia/Tahoe 使用 OCLP kext 驱动 BCM94360Z4。

## 快速开始（U 盘引导）

1. 下载本仓库 ZIP 并解压
2. 将解压后的 **`EFI/` 文件夹整体复制**到 U 盘根目录（U 盘需 FAT32 格式）
3. 最终 U 盘结构：`U:\EFI\BOOT\BOOTx64.efi` + `U:\EFI\OC\config.plist`
4. BIOS 启动项选择 **UEFI: U盘**，即可进入 OpenCore 引导菜单

> **注意**：请直接使用仓库根目录的 `EFI/` 文件夹，不要自己手动拼接 `OC/` 和 `BOOT/`，避免遗漏文件导致无法引导。

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
keepsyms=1 debug=0x100 rtcfx_exclude=80-AB darkwake=2 igfxonln=1 igfxagdc=0 e1000=1 -lilubetaall brcmfx-country=US
```

> 注：`brcmfx-country=US` 于 2026-07-22 添加，用于修复 WiFi country code。`io80211.awdl=1` 曾于同一天添加尝试启用 AWDL，因 AWDL 无法激活已移除（详见下方 AirDrop 章节）。
>
> 注：`amfi=0x80` 曾于 2026-07-21 添加（配合 AMFIPass.kext 在 SIP 0x0803 下放宽 AMFI 限制），但它在 macOS Ventura 13 上会导致系统卷校验失败出现禁止符号，已于 2026-08-22 移除。AMFIPass.kext 现通过 `MinKernel=23.0.0` 门禁仅用于 macOS 14+（Sequoia/Tahoe）。

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

**当前状态：不工作**

AirDrop 需要 AWDL（Apple Wireless Direct Link）协议在 WiFi 数据链路层建立点对点连接。本机 AWDL 始终无法激活。

**根因分析**（2026-07-22 深度调试）：

1. **MACF/Sandbox 阻止 IO80211AsyncEventUserClient**：airportd 等进程尝试通过 IOServiceOpen 打开 UserClient 时，被内核 MACF 框架拒绝（返回 `0xe00002e2` kIOReturnNotPermitted），被迫回退到 IOCTL 兼容路径
2. **类名不匹配**：OCLP-Mod 注入的旧版 IO80211FamilyLegacy kext 注册的类名为 `IO80211AsyncEventUserClient`（新名），而旧版 airportd 的 entitlement 期望 `IO80211APIUserClient`（旧名）
3. **无法同时满足**：将 kext 类名改为旧名可让 airportd 通过 MACF，但 rapportd 等新版进程的 Sandbox profile 期望新名；保持新名则 airportd 被拒绝
4. **重新签名 airportd 也无效**：MACF/Sandbox 只信任 Apple 平台二进制签名的 entitlements，adhoc 签名不被信任
5. **setUCMProfile 失败**：即使 IOServiceOpen 成功，setUCMProfile 通过 IOCTL 返回 "Operation not permitted"

**已尝试的修复**（6 个 kext 二进制 patch，最终全部回退）：

| # | 修改 | 作用 | 结果 |
|---|------|------|------|
| 1 | newUserClient type 检查绕过 | 允许 airportd 打开 UserClient | 0xe00002e2 → 0xe00002bc |
| 2 | initWithTask entitlement 检查绕过 | 绕过 kext 内部权限检查 | 进入下一层错误 |
| 3 | APFeatures: 1→15 | 启用 AWDL/AirDrop/AirPlay 标志位 | awdl0 接口激活但协议 inactive |
| 4 | VirtualInterface type 检查绕过 | 允许 awdl0 虚拟接口 UserClient | 部分推进 |
| 5 | VirtualInterface entitlement 检查绕过 | 绕过虚拟接口权限检查 | 部分推进 |
| 6 | kext 类名 AsyncEvent→API | 修复 airportd MACF 匹配 | airportd 通过但 rapportd 等被拒绝 |

**结论**：AWDL 在 OCLP-Mod 黑苹果架构下无法完整激活，是架构限制。AirDrop（苹果设备间）不可用。

> **注意**：蓝牙文件传输（发送给安卓等其他蓝牙设备）正常工作，不受影响。

### 启用的 Kext

> **跨版本门禁**：OCLP 相关 kext（AMFIPass、IOSkywalkFamily、IO80211FamilyLegacy、AirPortBrcmNIC）均设置 `MinKernel=23.0.0`，仅在 macOS 14+ 加载；Ventura 13 下 BCM94360Z4 由系统原生驱动，无需 OCLP kext。

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

BCM94360Z4 是 Apple 原生兼容网卡。WiFi 通过 `IO80211FamilyLegacy + AirPort_BrcmNIC` 原生驱动，配合 OCLP-Mod 2.6.9 Root Patch（注意：3.x 版本在 Sequoia 上不稳定，务必使用 2.6.9）。

蓝牙通过 UTBMap 的 **HS14（port 14）内部端口映射**工作。BCM94360Z4 的蓝牙通过 USB 接口连接到主板 XHCI 控制器的内部端口，UTBMap 将该端口标记为 `UsbConnector=255`（内部设备），macOS 才能枚举蓝牙设备。蓝牙使用 **USB transport**（非 UART），Address 和固件版本均正常。

蓝牙当前状态：
- 蓝牙连接和文件传输正常（可搜索和连接非苹果设备）
- **无法搜索到苹果自有设备**（如 iPhone、iPad），这是 OCLP-Mod 架构限制
- AirDrop（苹果设备间）不工作（AWDL 协议无法激活，详见上方章节）

> **注意**：EFI 中包含 AirportBrcmFixup (2.2.0) + brcmfx-country=US 用于修复 WiFi country code 问题。BrcmPatchRAM3 + BlueToolFixup + BrcmFirmwareData 用于蓝牙固件加载。

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

- macOS Ventura 13 启动（已验证，无禁止符号）
- macOS Sequoia 15.7.8 启动和安装
- Intel UHD 630 显示输出（HDMI）
- 无显示器启动（物理 HDMI 诱骗器，已确认正常工作）
- Intel I219 有线网卡
- WiFi（BCM94360Z4 原生驱动 + OCLP-Mod 2.6.9）
- 蓝牙（BCM94360Z4，UTBMap HS14 内部端口映射，USB transport，Address/Firmware 正常）
- 蓝牙文件传输（可连接非苹果设备，如安卓手机）
- USB 端口（UTBMap 定制映射，含内部蓝牙端口）
- CPU 电源管理

## 待完善

- 声卡（可能需要调整 layout-id）
- iCloud / iMessage（需生成唯一 SMBIOS 序列号）
- AirDrop（AWDL 架构限制，详见上方章节）
- 蓝牙搜索苹果自有设备（OCLP-Mod 架构限制）

## 注意事项

1. **SMBIOS 序列号**：配置中的序列号为占位符，使用 iCloud/iMessage 前必须用 [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) 为 Macmini8,1 生成你自己的序列号。

2. **无显示器启动**：EDID 注入（`AAPL00,override-no-connect`）对无显示器启动**无效**。问题在 UEFI GOP 阶段而非 macOS，iGPU 必须在开机自检时检测到显示设备才初始化。解决方案是使用物理 HDMI 诱骗器（插入 HDMI 口），让 GOP 认为"有显示器"。启动完成后拔掉诱骗器也不影响使用。**已确认 HDMI 诱骗器正常工作**。

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

OpenCore EFI for **HP ProDesk 600 G4 SFF** with **Intel Core i5-9500T**, compatible across macOS Ventura 13 / Sequoia 15 / Tahoe 26, currently running macOS Sequoia 15.7.8.

## Quick Start (USB Boot)

1. Download and extract this repository ZIP
2. Copy the entire **`EFI/` folder** to the root of your USB drive (USB must be FAT32)
3. Final USB structure: `U:\EFI\BOOT\BOOTx64.efi` + `U:\EFI\OC\config.plist`
4. Select **UEFI: USB drive** in BIOS to enter the OpenCore picker

> **Note**: Use the `EFI/` folder from the repo root directly. Do not manually assemble `OC/` and `BOOT/` to avoid missing files and boot failure.

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

- macOS Ventura 13 (tested, verified boot, no prohibition sign)
- macOS Sequoia 15.7.8 (Build 24G814) (tested)
- macOS Sequoia 15.7.7 (Build 24G720) (previous version, upgraded)
- macOS Tahoe 26 (theoretical; OCLP kexts gated with MinKernel=23.0.0)

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
keepsyms=1 debug=0x100 rtcfx_exclude=80-AB darkwake=2 igfxonln=1 igfxagdc=0 e1000=1 -lilubetaall brcmfx-country=US
```

> Note: `brcmfx-country=US` added 2026-07-22 to fix WiFi country code. `io80211.awdl=1` was added the same day to attempt AWDL activation but was removed because AWDL cannot activate (see AirDrop section below).
>
> Note: `amfi=0x80` was added 2026-07-21 to relax AMFI alongside AMFIPass.kext under SIP 0x0803, but it causes a boot volume verification failure (prohibition sign) on macOS Ventura 13, so it was removed 2026-08-22. AMFIPass.kext is now gated with `MinKernel=23.0.0` for macOS 14+ only (Sequoia/Tahoe).

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

**Current: Not working**

AirDrop requires AWDL (Apple Wireless Direct Link) protocol to establish peer-to-peer connections at the WiFi data link layer. AWDL could not be activated on this machine.

**Root Cause** (deep debugging on 2026-07-22):

1. **MACF/Sandbox blocks IO80211AsyncEventUserClient**: When airportd and other processes try to open UserClient via IOServiceOpen, the kernel MACF framework denies access (returns `0xe00002e2` kIOReturnNotPermitted), forcing fallback to IOCTL compatibility path
2. **Class name mismatch**: OCLP-Mod's injected legacy IO80211FamilyLegacy kext registers class name `IO80211AsyncEventUserClient` (new name), but the legacy airportd's entitlements expect `IO80211APIUserClient` (old name)
3. **Cannot satisfy both**: Changing kext class name to old name lets airportd pass MACF, but rapportd and other new-version processes' Sandbox profiles expect the new name; keeping new name blocks airportd
4. **Re-signing airportd also fails**: MACF/Sandbox only trusts entitlements from Apple platform binary signatures; adhoc signatures are not trusted
5. **setUCMProfile fails**: Even when IOServiceOpen succeeds, setUCMProfile via IOCTL returns "Operation not permitted"

**Attempted fixes** (6 kext binary patches, all ultimately reverted):

| # | Modification | Purpose | Result |
|---|---|---|---|
| 1 | newUserClient type check bypass | Allow airportd to open UserClient | 0xe00002e2 → 0xe00002bc |
| 2 | initWithTask entitlement check bypass | Bypass kext internal permission check | Progressed to next error |
| 3 | APFeatures: 1→15 | Enable AWDL/AirDrop/AirPlay flags | awdl0 interface active but protocol inactive |
| 4 | VirtualInterface type check bypass | Allow awdl0 virtual interface UserClient | Partial progress |
| 5 | VirtualInterface entitlement check bypass | Bypass virtual interface permission check | Partial progress |
| 6 | kext class name AsyncEvent→API | Fix airportd MACF matching | airportd passes but rapportd etc. blocked |

**Conclusion**: AWDL cannot be fully activated under OCLP-Mod hackintosh architecture. This is an architectural limitation. AirDrop (between Apple devices) is not available.

> **Note**: Bluetooth file transfer (sending to Android and other Bluetooth devices) works normally and is unaffected.

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

BCM94360Z4 is a native Apple-compatible card. WiFi uses `IO80211FamilyLegacy + AirPort_BrcmNIC` native driver with OCLP-Mod 2.6.9 Root Patch (note: 3.x versions are unstable on Sequoia, use 2.6.9 only).

Bluetooth works via UTBMap's **HS14 (port 14) internal port mapping**. BCM94360Z4's Bluetooth connects via USB to the XHCI controller's internal port. UTBMap marks this port as `UsbConnector=255` (internal device), allowing macOS to enumerate the Bluetooth device. Bluetooth uses **USB transport** (not UART), with normal Address and firmware version.

Current Bluetooth status:
- Bluetooth connection and file transfer work normally (can search and connect to non-Apple devices)
- **Cannot discover Apple devices** (e.g., iPhone, iPad) — this is an OCLP-Mod architectural limitation
- AirDrop (between Apple devices) does not work (AWDL protocol cannot be activated, see section above)

> **Note**: EFI includes AirportBrcmFixup (2.2.0) + brcmfx-country=US to fix WiFi country code. BrcmPatchRAM3 + BlueToolFixup + BrcmFirmwareData are used for Bluetooth firmware loading.

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

- macOS Ventura 13 boot (verified, no prohibition sign)
- macOS Sequoia 15.7.8 boot and installation
- Intel UHD 630 display output (HDMI)
- Headless boot (physical HDMI dummy plug, confirmed working)
- Intel I219 Ethernet
- WiFi (BCM94360Z4 native driver + OCLP-Mod 2.6.9)
- Bluetooth (BCM94360Z4, UTBMap HS14 internal port mapping, USB transport, Address/Firmware normal)
- Bluetooth file transfer (can connect to non-Apple devices, e.g., Android phones)
- USB ports (UTBMap custom mapping, including internal Bluetooth port)
- CPU power management

## What Needs Work

- Audio (may need layout-id adjustment)
- iCloud / iMessage (need to generate unique SMBIOS serials with GenSMBIOS)
- AirDrop (AWDL architectural limitation, see section above)
- Bluetooth discovery of Apple devices (OCLP-Mod architectural limitation)

## Important Notes

1. **SMBIOS Serials**: The serials in this config are placeholder values. You MUST generate your own using [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) for Macmini8,1 before using iCloud/iMessage.

2. **Headless Boot**: EDID injection (`AAPL00,override-no-connect`) does NOT work for headless boot. The issue is at the UEFI GOP phase, not macOS. iGPU must detect a display device during POST to initialize. The solution is a physical HDMI dummy plug (inserted into HDMI port) — once boot completes, removing the dummy plug doesn't affect usage. **HDMI dummy plug confirmed working**.

3. **Display Output**: This machine has 2x DisplayPort on rear. The framebuffer patch maps 3 HDMI connectors (type=0x0008) with busid 1/2/4. If only one port has signal, adjust the framebuffer busid values.

4. **OCLP-Mod Version**: BCM WiFi Root Patch must use **OCLP-Mod 2.6.9**. Version 3.x has signature stability issues on Sequoia.

5. **Bluetooth Port**: BCM94360Z4's Bluetooth uses XHCI internal port HS11. If you change the WiFi card or other hardware that shifts the Bluetooth port, you must update the corresponding UTBMap port mapping.

6. **Debug Log**: OpenCore logs are saved to `/var/log/OpenCore.log` on the macOS partition for troubleshooting.

7. **Migrating from USB to HDD**: After copying EFI to the hard disk EFI partition, set the hard disk boot entry as first priority in BIOS. Ensure the copy is complete, especially the executable files under `.kext/Contents/MacOS/`.

## Credits

- [Acidanthera](https://github.com/acidanthera) - OpenCore, Lilu, VirtualSMC, WhateverGreen, AppleALC, and more
- [Mieze](https://github.com/Mieze) - IntelMausiEthernet
- [Dortania](https://dortania.github.io) - OpenCore Install Guide

> AI生成