#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <hostname>"
    exit 1
fi

# The hostname of the remote machine
machine=$1

# Local backup directory
backup_dir="./bootnode_backup/"

# Ensure the required tools are installed
check_dependencies() {
    for cmd in ansible-inventory jq; do
        if ! command -v $cmd &> /dev/null; then
            echo "$cmd is required but not installed. Please install it."
            exit 1
        fi
    done
}

# Extract hostnames and networks from the inventory file
get_proxmox_nodes_and_networks() {
    local inventory_file=$1
    ansible-inventory -i "$inventory_file" --list | jq -r '
        .proxmox_nodes.children[] as $group |
        .[$group].hosts[] as $host |
        "\($host):\($group)"
    '
}

# Function to restore a secret key file
restore_secret_key() {
    local remote_path=$1
    local backup_filename=$2

    # Check if the remote secret key file exists
    if ssh "$machine" "[ -f $remote_path ]"; then
        # Backup the existing secret key file
        ssh "$machine" "mv $remote_path ${remote_path}.bak"
        echo "Existing secret key file backed up to ${remote_path}.bak on $machine."
    fi

    # Copy the new secret key file to the remote machine
    scp "$backup_dir/$backup_filename" "$machine:$remote_path"
    echo "Secret key file restored from $backup_filename to $remote_path on $machine."
}

# Main function to process each node and network
process_node() {
    local inventory_file="../inventory"
    local nodes_and_networks
    nodes_and_networks=$(get_proxmox_nodes_and_networks "$inventory_file")

    for node_network in $nodes_and_networks; do
        IFS=':' read -r node network <<< "$node_network"
        if [ "$node" == "$machine" ]; then
            echo "Processing $machine for network $network..."
            local base_path="/opt/$network/chains"
            local sub_networks
            sub_networks=$(ssh "$machine" "ls $base_path")

            for sub_network in $sub_networks; do
                local secret_key_path="$base_path/$sub_network/network/secret_ed25519"
                for backup_file in "$backup_dir"/*; do
                    IFS='_' read -r remote_hostname network peer_id <<< "$(basename "$backup_file" .secret_ed25519)"
                    if [ "$remote_hostname" == "$node" ]; then
                        restore_secret_key "$secret_key_path" "$(basename "$backup_file")"
                    fi
                done
            done
        fi
    done
}

main() {
    check_dependencies

    local inventory_file="../inventory"
    process_node

    echo "All restore operations completed."
}

main

