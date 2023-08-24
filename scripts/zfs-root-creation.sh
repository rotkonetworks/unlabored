o#add
#!/bin/bash

set -e
set -u
set -o pipefail

POOL_NAME="tank03"
SWAP_SIZE=64G
ZFS_ARC_MAX=68719476736 # Limit ARC to 64GB
RAID_FORMAT="raidz"     # Options: mirror, raidz, raidz2, raidz3, striped

# Disks array
declare -a DISKS=("nvme0n1" "nvme1n1" "nvme2n1" "nvme3n1" "nvme4n1")

check_disk_availability() {
	for disk in "${DISKS[@]}"; do
		if ! lsblk | grep -q "$disk"; then
			echo "Error: Disk ${disk} not found."
			exit 1
		fi
	done
}

initialize_zfs_pool() {
	local pool_name="$1"
	local raid_format="$2"
	shift 2
	local disks=("$@")

	# Ensure that the desired pool doesn't already exist
	if zpool list | grep -q "^${pool_name}"; then
		echo "Error: Pool named ${pool_name} already exists."
		exit 1
	fi

	echo "Creating ZFS pool named ${pool_name} with format ${raid_format}..."

	case "${raid_format}" in
	mirror)
		[[ ${#disks[@]} -ge 2 ]] || {
			echo "Error: Not enough disks for mirror."
			exit 1
		}
		;;
	raidz | raidz2 | raidz3)
		[[ ${#disks[@]} -ge 3 ]] || {
			echo "Error: Not enough disks for ${raid_format}."
			exit 1
		}
		;;
	esac

	zpool create -o ashift=12 "${pool_name}" "${raid_format}" "${disks[@]}"
	echo "ZFS pool ${pool_name} created."
}

configure_zfs_settings() {
	local pool_name="$1"

	echo "Configuring ZFS settings for pool ${pool_name}..."

	# Tweak settings specifically for blockchain workloads in one command
	zfs set atime=off recordsize=16k logbias=throughput primarycache=metadata compression=lz4 redundant_metadata=most sync=standard "${pool_name}"
	echo "ZFS settings applied."
}

create_root_dataset() {
	local pool_name="$1"
	zfs create "${pool_name}/root"
	echo "Root dataset for ${pool_name} created."
}

create_swap_zvol() {
	local pool_name="$1"
	local swap_size="$2"

	zfs create -V "${swap_size}" -b $(getconf PAGESIZE) -o compression=zle \
		-o logbias=throughput -o sync=always \
		-o primarycache=metadata -o secondarycache=none \
		"${pool_name}/swap"

	mkswap -f "/dev/zvol/${pool_name}/swap"
	swapon "/dev/zvol/${pool_name}/swap"

	# Add swap entry to fstab
	echo "/dev/zvol/${pool_name}/swap none swap defaults 0 0" >>/etc/fstab
	echo "ZFS swap created and activated."
}

limit_zfs_arc_size() {
	local arc_size="$1"
	echo "options zfs zfs_arc_max=${arc_size}" >>/etc/modprobe.d/zfs.conf
	echo "ZFS ARC limited to ${arc_size}."
}

check_proxmox_installed() {
	if ! command -v pvesm &>/dev/null; then
		echo "Proxmox utilities not found. Ensure Proxmox is installed."
		exit 1
	fi
}

integrate_with_proxmox() {
	check_proxmox_installed

	local pool_name="$1"
	pvesm add zfspool "${pool_name}" -f
	pvesm update "${pool_name}"

	echo "ZFS pool integrated with Proxmox."
}

main() {
	check_disk_availability
	initialize_zfs_pool "${POOL_NAME}" "${RAID_FORMAT}" "${DISKS[@]}"
	configure_zfs_settings "${POOL_NAME}"
	create_root_dataset "${POOL_NAME}"
	create_swap_zvol "${POOL_NAME}" "${SWAP_SIZE}"
	limit_zfs_arc_size "${ZFS_ARC_MAX}"
	integrate_with_proxmox "${POOL_NAME}"

	echo "ZFS setup completed."
}

main "$@"
