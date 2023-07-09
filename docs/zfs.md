# Filesystem

I have gone through multiple filesystems in search for the most optimal
for blockchain usecase. ext4 doesn't scale, mdraid and lvm doesn't flex,
btrfs has poor UX and so so support on Proxmox yet. ZFS is incredible.

## Zpool

Create with -o ashift=12 and use PARTUUIDs instead of /dev/nvme0n1p1
to avoid headache when required to replace something. It is possible
tho to always import disks back if they lose ID with decent success
rate.

## Validator settings (ParityDB):
```bash
zfs set recordsize=16K tank
zfs set redundant_metadata=most tank
zfs set atime=off tank
zfs set logbias=throughput tank
zfs set compression=lz4 tank
zfs set primarycache=metadata tank
```

Every single chain has its optimal specs and need to be adjusted
accordingly for use case and recordsize.
