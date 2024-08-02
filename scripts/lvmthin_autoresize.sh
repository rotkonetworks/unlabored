#!/bin/bash
# This script checks the usage of LVM thin volumes and resizes them if they are over a certain threshold.
# Italso updates the LXC configuration file to reflect the new size of the disk.
# To use the script with VMs instead of LXC containers, replace the 'pct' commands with 'qm' commands.

# Define constants
THRESHOLD=90
RESIZE_FACTOR=1.1
LOG_FILE="/var/log/lvm_resize.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to resize a logical volume and update filesystem
resize_lv() {
    local LV_PATH="$1"
    local LV_NAME="$(echo "$LV_PATH" | awk -F '/' '{print $NF}')"
    local VG_NAME="$(echo "$LV_PATH" | awk -F '/' '{print $(NF-1)}')"
    local CURRENT_SIZE_GB=$(lvs --noheadings --units g -o LV_SIZE "$VG_NAME/$LV_NAME" | awk '{print int($1)}')
    local NEW_SIZE_GB=$(echo "$CURRENT_SIZE_GB * $RESIZE_FACTOR / 1" | bc)
    NEW_SIZE_GB=$(echo "$NEW_SIZE_GB/1" | bc) # Ensure new size is an integer number of GB
    local CONTAINER_ID=$(echo "$LV_PATH" | grep -oP 'vm-\K[0-9]+(?=-disk)')

    log_message "Stopping container ID $CONTAINER_ID for resize operation..."
    if ! pct stop $CONTAINER_ID; then
        log_message "Failed to stop container ID $CONTAINER_ID. Aborting resize operation."
        return 1
    fi

    log_message "Resizing $LV_PATH from ${CURRENT_SIZE_GB}G to ${NEW_SIZE_GB}G..."
    if ! lvresize --resizefs --size "${NEW_SIZE_GB}G" "$LV_PATH"; then
        log_message "Error resizing $LV_PATH. Attempting to start container ID $CONTAINER_ID..."
        if ! pct start $CONTAINER_ID; then
            log_message "Critical error: failed to start container ID $CONTAINER_ID after resize failure."
        fi
        return 1
    fi

    update_lxc_config "$LV_PATH" "$NEW_SIZE_GB"

    log_message "Successfully resized $LV_PATH. Starting container ID $CONTAINER_ID..."
    if ! pct start $CONTAINER_ID; then
        log_message "Failed to start container ID $CONTAINER_ID after resizing."
        return 1
    fi

    log_message "Container ID $CONTAINER_ID started successfully after resizing."
}

update_lxc_config() {
    local LV_PATH="$1"
    local NEW_SIZE_GB="$2"
    local CONTAINER_ID=$(echo "$LV_PATH" | grep -oP 'vm-\K[0-9]+(?=-disk)')
    local DISK_NAME=$(echo "$LV_PATH" | awk -F '/' '{print $NF}')
    local CONFIG_PATH="/etc/pve/lxc/${CONTAINER_ID}.conf"

    if [[ ! -f "$CONFIG_PATH" ]]; then
        log_message "Configuration file for container ID $CONTAINER_ID does not exist."
        return 1
    fi

    # Find the line with the disk and update its size
    local PATTERN="(${DISK_NAME},size=)[^,]+"
    sed -ri "s|$PATTERN|\1${NEW_SIZE_GB}G|" "$CONFIG_PATH"

    if [[ $? -eq 0 ]]; then
        log_message "Successfully updated the LXC configuration for container ID $CONTAINER_ID."
    else
        log_message "Failed to update the LXC configuration for container ID $CONTAINER_ID."
        return 1
    fi
}

# Main loop to check each LVM volume
while IFS= read -r line; do
    DISK_NAME=$(echo "$line" | awk '{print $1}')
    POOL_NAME=$(echo "$line" | awk '{print $2}')
    DATA_PERCENT=$(echo "$line" | awk '{print $6}' | sed 's/%//')

    if [ "$(echo "$DATA_PERCENT > $THRESHOLD" | bc)" -ne 0 ]; then
        log_message "Volume $DISK_NAME is over ${THRESHOLD}% full."
        if ! resize_lv "/dev/$POOL_NAME/$DISK_NAME"; then
            log_message "Failed to resize volume $DISK_NAME. Check logs for details."
        fi
    fi
done < <(lvs --units g --separator ' ' --noheadings | grep -v swap)

log_message "Check and resize operation completed."
