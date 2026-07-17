/*
 * SSDT-BT - Bluetooth _DSM injection for BCM94360Z4 on HP ProDesk 600 G4 SFF
 *
 * Problem: The UBTC ACPI device in HP BIOS has no _DSM method, causing
 * IOBluetoothACPIMethods to return empty properties {}. Additionally,
 * IOBluetoothHCIController defaults to UART transport (0), but BCM94360Z4
 * bluetooth uses USB transport internally.
 *
 * Solution: Inject _DSM method via Scope (_SB.UBTC) with:
 *   - Transport = 1 (USB, not UART)
 *   - power-state = 1 (powered on)
 *   - BTLP = {100, 0} (low power config)
 *   - Bluetooth claimed address = 00:00:00:00:00:00
 *
 * No ACPI rename is needed - we inject directly into the existing device.
 */
DefinitionBlock ("SSDT-BT", "SSDT", 2, "HACK", "BT", 0x00000000)
{
    External (_SB.UBTC, DeviceObj)    // Reference to existing UBTC device in DSDT

    Scope (_SB.UBTC)
    {
        Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
        {
            If (LEqual (Arg2, Zero))
            {
                Return (Buffer (One) { 0x00 })
            }

            Return (Package (0x08)
            {
                "power-state",
                One,                              // Power state = ON (1)
                "Transport",
                One,                              // Transport = USB (1), not UART (0)
                "BTLP",
                Package (0x02) { 0x64, 0x00 },    // Low Power: 100ms timeout
                "Bluetooth claimed address",
                Buffer (0x06) { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }
            })
        }
    }
}
