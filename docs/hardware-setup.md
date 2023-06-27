# Hardware setup:
Update drivers, BIOS/firmware.
Install NVMe drivers.

## Installation Partitioning:
1. Use manual partitioning.
2. If only NVMe storage, use USB stick for initial partitions.
3. Recommended separate boot on USB to prevent boot loss from disk failure.
## Partition Specs:
```
/boot: 1GB, ext4 journaled
EFI Partition: 1GB
/swap: 50% of total RAM
/: 256GB, ext4 journaled
```
Rest: LINUX LVM, no RAID setup (later purposed as zfs/btrfs)

## Installation Procedure:
- Prepare 2 USBs: one for Debian installer, one empty for boot.
- Download Debian ISO, make bootable USB with Rufus or Etcher.
- Boot from USB, select "Install".
- Choose language, location, keyboard layout.
- Select "Manual partitioning".
- If only NVMe storage, create partitions on USB stick; else, on NVMe disk.
- Create GPT partition table for boot stick using parted (type mklabel, enter gpt).
- Create /boot partition (1GB, ext4), using parted.
- Create EFI partition (1GB, fat32), using parted.
- Create other necessary partitions.
- Select "Finish partitioning and write changes to disk".
- Continue with installation: timezone, root password, user account.
- Install GRUB on device with EFI system partition (e.g., /dev/sda).
- Reboot system, verify boot from NVMe disk/USB stick.
- Ensure correct UUIDs for /boot and / in fstab, update GRUB if needed.
