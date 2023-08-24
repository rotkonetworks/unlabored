#!/bin/bash

set -e
set -o pipefail

ISO_PATH="/home/user/Downloads/debian-12.1.0-amd64-netinst.iso"
USB_DEVICE="/dev/sda"

get_package_manager() {
	# Try to detect the package manager
	if command -v apt &>/dev/null; then
		echo "apt"
	elif command -v pacman &>/dev/null; then
		echo "pacman"
	else
		echo "Unknown"
	fi
}

install_package() {
	local package=$1
	case $(get_package_manager) in
	apt)
		sudo apt update
		sudo apt install -y "$package"
		;;
	pacman)
		sudo pacman -Sy --noconfirm "$package"
		;;
	*)
		echo "Error: Unsupported package manager."
		exit 1
		;;
	esac
}

# Check if the ISO exists
if [ ! -f "$ISO_PATH" ]; then
	echo "Error: ISO file not found at $ISO_PATH"
	exit 1
fi

# Verify that the USB_DEVICE is indeed a USB device
if ! lsblk -dno NAME,TRAN $USB_DEVICE | grep -q usb; then
	echo "Error: $USB_DEVICE does not appear to be a USB device. Exiting for safety."
	exit 1
fi

# Prompt for confirmation
read -p "All data on $USB_DEVICE will be destroyed. Are you sure you want to proceed? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	exit 1
fi

# Unmount existing partitions
for partition in $(lsblk -lno NAME $USB_DEVICE | grep "^${USB_DEVICE##*/}"); do
	umount "/dev/$partition" || true
done

# Create the partitions using gdisk
echo -e "o\ny\nn\n\n\n+1G\nEF00\nn\n\n\n+2G\n8300\nn\n\n\n\n8300\nw\ny" | sudo gdisk $USB_DEVICE

# Format the partitions
sudo mkfs.vfat -F32 ${USB_DEVICE}1 # EFI partition
sudo mkfs.ext4 ${USB_DEVICE}2      # /boot partition
sudo mkfs.ext4 ${USB_DEVICE}3      # /root partition

# Mount the partitions
sudo mkdir -p /mnt/usb/{boot,root}
sudo mount ${USB_DEVICE}2 /mnt/usb/boot
sudo mount ${USB_DEVICE}3 /mnt/usb/root
sudo mount ${USB_DEVICE}1 /mnt/usb

# Write the Debian Live ISO to the /boot partition
sudo dd if=$ISO_PATH of=${USB_DEVICE}2 bs=4M status=progress

# Install GRUB for UEFI on the EFI partition
if [[ $(get_package_manager) == "apt" ]] && ! dpkg -l | grep -q grub-efi-amd64-bin; then
	install_package grub-efi-amd64-bin
elif [[ $(get_package_manager) == "pacman" ]]; then
	if ! pacman -Qq | grep -q grub; then
		install_package grub
	fi
	if ! pacman -Qq | grep -q efibootmgr; then
		install_package efibootmgr
	fi
fi
sudo grub-install --target=x86_64-efi --boot-directory=/mnt/usb/boot --efi-directory=/mnt/usb --removable

# Update GRUB configuration
sudo mount ${USB_DEVICE}1 /mnt/usb
sudo grub-mkconfig -o /mnt/usb/boot/grub/grub.cfg

# Unmount and clean up
sudo umount /mnt/usb/{boot,root}
sudo umount /mnt/usb
rm -rf /mnt/usb

echo "USB preparation complete."
