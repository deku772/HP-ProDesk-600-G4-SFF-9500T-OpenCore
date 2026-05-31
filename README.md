---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: 'a1264b4e-1805-4470-916f-4c1b75a10d77'
  PropagateID: 'a1264b4e-1805-4470-916f-4c1b75a10d77'
  ReservedCode1: '54f23d51-40f6-4b3b-90c2-5d240d227fad'
  ReservedCode2: '54f23d51-40f6-4b3b-90c2-5d240d227fad'
---

---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: '872fc850-2bab-4ad0-91ec-3d0152415a84'
  PropagateID: '872fc850-2bab-4ad0-91ec-3d0152415a84'
  ReservedCode1: '90127921-edaf-481e-a109-506c171ca059'
  ReservedCode2: '90127921-edaf-481e-a109-506c171ca059'
---

---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: '62109443-a5bb-45ce-93f2-1204c92726c8'
  PropagateID: '62109443-a5bb-45ce-93f2-1204c92726c8'
  ReservedCode1: 'c3205161-2426-4da0-b5e4-7872fcc3b9ea'
  ReservedCode2: 'c3205161-2426-4da0-b5e4-7872fcc3b9ea'
---

---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: 'aaeccb35-1291-43fe-be29-fe92754ded04'
  PropagateID: 'aaeccb35-1291-43fe-be29-fe92754ded04'
  ReservedCode1: 'bffe78f8-c2b2-4296-bd53-47b354f8d20b'
  ReservedCode2: 'bffe78f8-c2b2-4296-bd53-47b354f8d20b'
---

---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: 'b29d1eed-fba8-4ab9-977a-f2495cb539eb'
  PropagateID: 'b29d1eed-fba8-4ab9-977a-f2495cb539eb'
  ReservedCode1: 'c0a8ca81-a00d-41fa-9bf8-4e0c96dee8c2'
  ReservedCode2: 'c0a8ca81-a00d-41fa-9bf8-4e0c96dee8c2'
---

---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: 'c63f9043-7444-47c9-ad14-72234d43f550'
  PropagateID: 'c63f9043-7444-47c9-ad14-72234d43f550'
  ReservedCode1: '00f7f5b2-91c5-4cc8-ac7e-2533077a26b2'
  ReservedCode2: '00f7f5b2-91c5-4cc8-ac7e-2533077a26b2'
---

---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: 'b7ba35f9-bf20-433c-8b85-29ff14af6548'
  PropagateID: 'b7ba35f9-bf20-433c-8b85-29ff14af6548'
  ReservedCode1: 'd0d4c90e-99d3-4ba7-8046-ee2c6ef1894f'
  ReservedCode2: 'd0d4c90e-99d3-4ba7-8046-ee2c6ef1894f'
---

---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: 'cdb83658-b873-48f1-9efd-41c03d8ef25e'
  PropagateID: 'cdb83658-b873-48f1-9efd-41c03d8ef25e'
  ReservedCode1: '01785907-33de-4acb-9963-09409fef78d1'
  ReservedCode2: '01785907-33de-4acb-9963-09409fef78d1'
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
| WiFi/蓝牙 | Broadcom BCM94360CS2（已更换，原生支持 + AirportBrcmFixup + BrcmPatchRAM3） |

## BIOS 设置

使用本 EFI 前需在 BIOS 中完成以下设置：

| 选项 | 路径 | 设置值 | 说明 |
|---|---|---|---|
| VT-d | Advanced → System Configuration → VT-d | **Disabled** | 已通过 DisableIoMapper 禁用，BIOS 也需关闭避免冲突 |
| DVMT Pre-Allocated | Advanced → System Agent (SA) Configuration → DVMT Pre-Allocated | **64MB** | macOS 按 ig-platform-id 分配显存，设为 512MB 会导致内存映射错乱无法启动 |
| Secure Boot | Boot → Secure Boot → Secure Boot | **Disabled** | OpenCore 不支持 UEFI Secure Boot，必须关闭 |

## OpenCore 版本

**OpenCore 1.0.7**

## macOS 兼容性

- macOS Sequoia 15.5.7（已测试）

## SMBIOS

`Macmini8,1`，配合 `CustomSMBIOSGuid=true` + `revpatch=sbvmm`

> ⚠️ 配置中的序列号为随机生成，使用 iCloud/iMessage 前必须自行生成并验证唯一性（见下方说明）。

## 关键配置

### 核显 (DeviceProperties)

- `ig-platform-id`：`0x3E920000`（UHD 630，含帧缓冲补丁）
- 3 个 DisplayPort 帧缓冲端口映射（con0/con1/con2）
- `igfxagdc=0`（禁用 AGDC 电源管理）

### 启动参数

```
keepsyms=1 debug=0x100 rtcfx_exclude=80-AB darkwake=2 igfxonln=1 igfxagdc=0 e1000=1
```

> 注：日常使用不跑马（无 `-v`）。如需调试，在 boot-args 末尾加 `-v` 即可。

### 启用的 Kext

| Kext | 版本 | 用途 |
|---|---|---|
| Lilu | 1.7.2 | 补丁引擎 |
| AirportBrcmFixup | 2.2.0 | Broadcom WiFi 补丁 |
| BrcmFirmwareData | 2.7.2 | Broadcom BT 固件数据（BrcmPatchRAM3 依赖） |
| BrcmPatchRAM3 | 2.7.2 | Broadcom BT 固件上传（macOS 12+） |
| VirtualSMC | 1.3.7 | SMC 仿真 |
| WhateverGreen | 1.7.0 | 核显补丁 |
| IntelMausiEthernet | 3.0.3 | Intel I219 有线网卡 |
| AppleALC | 1.9.7 | 声卡驱动 |
| SMCProcessor | 1.3.7 | CPU 温度监控 |
| SMCSuperIO | 1.3.7 | 风扇转速监控 |
| NVMeFix | 1.1.3 | NVMe 电源管理 |
| RestrictEvents | 1.1.6 | 系统更新修正 |
| USBToolBox | 1.1.1 | USB 端口映射工具 |
| UTBMap | 1.1 | USB 端口映射数据（本机定制） |

> 注：BlueToolFixup 已禁用，仅用于 Intel 蓝牙；BCM94360CS2 使用 BrcmPatchRAM3 替代。

### Booter Quirks

- `RebuildAppleMemoryMap=true`
- `SetupVirtualMap=false`（HP OEM 主板必须为 false）
- `EnableWriteUnprotector=false`
- `DevirtualiseMmio=true`
- `ProtectUefiServices=true`
- `FixupAppleEfiImages=true`
- `AvoidRuntimeDefrag=true`
- `ProvideCustomSlide=true`

### Kernel Quirks

- `AppleXcpmCfgLock=true`
- `CustomSMBIOSGuid=true`
- `DisableIoMapper=true`
- `DisableIoMapperMapping=true`
- `DisableLinkeditJettison=true`
- `DisableRtcChecksum=true`
- `LapicKernelPanic=true`
- `PanicNoKextDump=true`
- `PowerTimeoutKernelPanic=true`

### 已禁用的 Booter Patch

- **Skip Board ID check**：已禁用。OTA 升级后二进制偏移量变化会导致匹配失败卡死。

### UEFI 驱动

- OpenHfsPlus.efi
- OpenRuntime.efi
- OpenCanopy.efi（图形化启动选择器）
- OpenUsbKbDxe.efi（USB 键盘支持，HP OEM 主板必需）
- ResetNvramEntry.efi

## 正常工作的功能

- ✅ macOS Sequoia 启动和安装
- ✅ Intel UHD 630 显示输出（DisplayPort）
- ✅ Intel I219 有线网卡
- ✅ WiFi（Broadcom BCM94360CS2，AirportBrcmFixup）
- ✅ 蓝牙（Broadcom BCM94360CS2，BrcmPatchRAM3）
- ✅ USB 端口（已用 USBToolBox 定制映射）
- ✅ 声卡（layout-id 23）
- ✅ CPU 电源管理
- ✅ NVMe 电源管理
- ✅ 从 15.5.5 OTA 升级到 15.5.7

## 待完善

- **iCloud / iMessage**：需要用 GenSMBIOS 为 Macmini8,1 生成并验证唯一序列号（见下方说明）

## 序列号验证方法

配置中的序列号为随机生成，**必须验证唯一性后才能使用 iCloud/iMessage**：

1. 用 [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) 为 `Macmini8,1` 生成序列号（Serial + MLB + UUID）
2. 打开 Apple 保修查询页面：https://checkcoverage.apple.com
3. 输入生成的 Serial Number
4. 如果显示 **"无效序列号" 或 "购买日期未验证"** → ✅ 可用（没有和真机冲突）
5. 如果显示某台 Mac 的保修信息 → ❌ 不可用，重新生成
6. 将验证通过的序列号替换到 config.plist 的 `SystemSerialNumber`、`MLB`、`SystemUUID` 三处

## 注意事项

1. **SMBIOS 序列号**：当前配置中的序列号未经验证，使用 iCloud/iMessage 前必须自行生成并验证（见上方）。

2. **USB 映射**：已使用 USBToolBox 在本机生成定制映射（UTBMap.kext），如更换硬件需重新生成。

3. **DisplayPort 端口**：本机背面有 2 个 DP 口。当前帧缓冲补丁映射了 3 个 DP 连接器。如果只有一个口有信号，需调整 framebuffer busid 值。

4. **Skip Board ID check**：此 Booter Patch 已禁用。如果未来 macOS 更新需要重新启用，需用 OpenCore 对应版本重新计算偏移量。

5. **SetupVirtualMap**：HP OEM 主板必须保持 `false`，设为 `true` 会导致无法启动。

6. **编辑 config.plist**：**不要用 Python plistlib 编辑**，它会破坏 XML plist 格式导致无限重启。请用纯文本编辑器或 ProperTree。

7. **从 U 盘迁移到硬盘**：复制 EFI 到硬盘 EFI 分区后，需在 BIOS 中将硬盘启动项设为第一优先级。确保复制完整，特别是 `.kext/Contents/MacOS/` 下的可执行文件不能遗漏。

## 致谢

- [Acidanthera](https://github.com/acidanthera) - OpenCore、Lilu、VirtualSMC、WhateverGreen、AppleALC 等
- [Mieze](https://github.com/Mieze) - IntelMausiEthernet
- [USBToolBox](https://github.com/USBToolBox/tool) - USB 端口映射工具
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
| WiFi/Bluetooth | Broadcom BCM94360CS2 (aftermarket, native support + AirportBrcmFixup + BrcmPatchRAM3) |

## BIOS Settings

The following BIOS settings must be applied before using this EFI:

| Option | Path | Value | Note |
|---|---|---|---|
| VT-d | Advanced → System Configuration → VT-d | **Disabled** | Also disabled via DisableIoMapper quirk; must be off in BIOS to avoid conflicts |
| DVMT Pre-Allocated | Advanced → System Agent (SA) Configuration → DVMT Pre-Allocated | **64MB** | macOS allocates VRAM based on ig-platform-id, not BIOS DVMT. Setting 512MB causes memory map corruption and boot failure |
| Secure Boot | Boot → Secure Boot → Secure Boot | **Disabled** | OpenCore does not support UEFI Secure Boot; must be disabled |

## OpenCore Version

**OpenCore 1.0.7**

## macOS Compatibility

- macOS Sequoia 15.5.7 (tested)

## SMBIOS

`Macmini8,1` with `CustomSMBIOSGuid=true` + `revpatch=sbvmm`

> ⚠️ Serial numbers in this config are randomly generated. You MUST generate and verify unique serials before using iCloud/iMessage (see below).

## Key Configuration

### DeviceProperties (iGPU)

- `ig-platform-id`: `0x3E920000` (UHD 630 with framebuffer patches)
- 3x DisplayPort framebuffer mapping (con0/con1/con2)
- `igfxagdc=0` (disable AGDC power management)

### Boot Arguments

```
keepsyms=1 debug=0x100 rtcfx_exclude=80-AB darkwake=2 igfxonln=1 igfxagdc=0 e1000=1
```

> Note: No `-v` flag for daily use. Add `-v` to boot-args for verbose debugging.

### Enabled Kexts

| Kext | Version | Purpose |
|---|---|---|
| Lilu | 1.7.2 | Patch engine |
| AirportBrcmFixup | 2.2.0 | Broadcom WiFi patches |
| BrcmFirmwareData | 2.7.2 | Broadcom BT firmware data (required by BrcmPatchRAM3) |
| BrcmPatchRAM3 | 2.7.2 | Broadcom BT firmware upload for macOS 12+ |
| VirtualSMC | 1.3.7 | SMC emulator |
| WhateverGreen | 1.7.0 | iGPU patches |
| IntelMausiEthernet | 3.0.3 | Intel I219 LAN |
| AppleALC | 1.9.7 | Audio |
| SMCProcessor | 1.3.7 | CPU temp monitoring |
| SMCSuperIO | 1.3.7 | Fan speed monitoring |
| NVMeFix | 1.1.3 | NVMe power management |
| RestrictEvents | 1.1.6 | System update fix |
| USBToolBox | 1.1.1 | USB port mapping tool |
| UTBMap | 1.1 | USB port mapping data (custom for this machine) |

> Note: BlueToolFixup is disabled (Intel BT only); BCM94360CS2 uses BrcmPatchRAM3 instead.

### Booter Quirks

- `RebuildAppleMemoryMap=true`
- `SetupVirtualMap=false` (HP OEM board requires false)
- `EnableWriteUnprotector=false`
- `DevirtualiseMmio=true`
- `ProtectUefiServices=true`
- `FixupAppleEfiImages=true`
- `AvoidRuntimeDefrag=true`
- `ProvideCustomSlide=true`

### Kernel Quirks

- `AppleXcpmCfgLock=true`
- `CustomSMBIOSGuid=true`
- `DisableIoMapper=true`
- `DisableIoMapperMapping=true`
- `DisableLinkeditJettison=true`
- `DisableRtcChecksum=true`
- `LapicKernelPanic=true`
- `PanicNoKextDump=true`
- `PowerTimeoutKernelPanic=true`

### Disabled Booter Patch

- **Skip Board ID check**: Disabled. Binary offset changes after OTA updates can cause boot hang.

### UEFI Drivers

- OpenHfsPlus.efi
- OpenRuntime.efi
- OpenCanopy.efi (GUI picker)
- OpenUsbKbDxe.efi (USB keyboard support, required for HP OEM)
- ResetNvramEntry.efi

## What Works

- ✅ macOS Sequoia boot and installation
- ✅ Intel UHD 630 display output (DisplayPort)
- ✅ Intel I219 Ethernet
- ✅ WiFi (Broadcom BCM94360CS2, AirportBrcmFixup)
- ✅ Bluetooth (Broadcom BCM94360CS2, BrcmPatchRAM3)
- ✅ USB ports (custom mapped with USBToolBox)
- ✅ Audio (layout-id 23)
- ✅ CPU power management
- ✅ NVMe power management
- ✅ OTA upgrade from 15.5.5 to 15.5.7

## What Needs Work

- **iCloud / iMessage**: Need to generate and verify unique SMBIOS serials with GenSMBIOS (see below)

## Serial Number Verification

The serials in this config are randomly generated. **You MUST verify uniqueness before using iCloud/iMessage:**

1. Generate serials for `Macmini8,1` using [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) (Serial + MLB + UUID)
2. Open Apple's warranty check: https://checkcoverage.apple.com
3. Enter the generated Serial Number
4. If it shows **"Invalid serial" or "Purchase date not verified"** → ✅ Safe to use (no conflict with real Mac)
5. If it shows warranty info for a Mac → ❌ Conflict, regenerate
6. Replace `SystemSerialNumber`, `MLB`, and `SystemUUID` in config.plist with verified serials

## Important Notes

1. **SMBIOS Serials**: Current serials are unverified. Generate and verify your own before using iCloud/iMessage.

2. **USB Mapping**: Custom mapping generated with USBToolBox (UTBMap.kext). Rebuild if hardware changes.

3. **DisplayPorts**: This machine has 2x DisplayPort on rear. The framebuffer patch maps 3 DP connectors. Adjust busid values if only one port has signal.

4. **Skip Board ID check**: This Booter Patch is disabled. If a future macOS update requires it, recalculate offsets for the corresponding OpenCore version.

5. **SetupVirtualMap**: Must remain `false` on HP OEM boards. Setting `true` causes boot failure.

6. **Editing config.plist**: **Do NOT use Python plistlib** — it corrupts XML plist format and causes infinite reboots. Use a plain text editor or ProperTree.

7. **Migrating from USB to HDD**: After copying EFI to the hard disk EFI partition, set the hard disk boot entry as first priority in BIOS. Ensure the copy is complete, especially executables under `.kext/Contents/MacOS/`.

## Credits

- [Acidanthera](https://github.com/acidanthera) - OpenCore, Lilu, VirtualSMC, WhateverGreen, AppleALC, and more
- [Mieze](https://github.com/Mieze) - IntelMausiEthernet
- [USBToolBox](https://github.com/USBToolBox/tool) - USB port mapping tool
- [Dortania](https://dortania.github.io) - OpenCore Install Guide