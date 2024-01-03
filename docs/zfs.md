# Filesystem

ZFS is great filesystem for keeping storage but its terrible for running
blockchains. Performance drop is over 50% in comparison to lvm-thin with ext4.
For running validators its absolutely no go but for RPC nodes it might do the job.
Anyhow in retrospective I would recommend to use lvm-thin with ext4 for
even RPC nodes.

## Zpool

Create with -o ashift=12 and use PARTUUIDs instead of /dev/nvme0n1p1
to avoid headache when required to replace something. It is possible
tho to always import disks back if they lose ID with decent success
rate.

## Validator settings (ParityDB):
```bash
zfs set recordsize=4k tank
zfs set redundant_metadata=most tank
zfs set atime=off tank
zfs set logbias=throughput tank
zfs set compression=lz4 tank
zfs set primarycache=metadata tank
```

Every single chain has its optimal specs and need to be adjusted
accordingly for use case and recordsize.
