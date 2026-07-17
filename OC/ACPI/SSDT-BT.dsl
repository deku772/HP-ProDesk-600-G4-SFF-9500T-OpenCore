/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20260408 (64-bit version)
 * Copyright (c) 2000 - 2026 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of /Users/mysa/.local/share/TeleAgent/TeleAgent的工作空间/.temp/HP-ProDesk-600-G4-SFF-9500T-OpenCore/OC/ACPI/SSDT-BT.aml
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00000095 (149)
 *     Revision         0x02
 *     Checksum         0xE7
 *     OEM ID           "HACK"
 *     OEM Table ID     "BT"
 *     OEM Revision     0x00000000 (0)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20260408 (539362312)
 */
DefinitionBlock ("", "SSDT", 2, "HACK", "BT", 0x00000000)
{
    External (_SB_.UBTC, DeviceObj)

    Scope (_SB.UBTC)
    {
        Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
        {
            If (!Arg2)
            {
                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }

            Return (Package (0x06)
            {
                "power-state", 
                One, 
                "Bluetooth claimed address", 
                Buffer (0x06)
                {
                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00               // ......
                }, 

                "BTLP", 
                Package (0x02)
                {
                    0x64, 
                    Zero
                }
            })
        }
    }
}

