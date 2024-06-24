#!/bin/bash

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

# Process a single node for backup
process_node() {
    local machine=$1
    local network=$2
    local failures_file="failures.tmp"

    echo "Processing $machine for network $network..."

    if ! ssh "$machine" "wget -q $genpeerid_url -O $genpeerid_path && chmod +x $genpeerid_path"; then
        echo "$machine:$network - Failed to download genpeerid binary" >> $failures_file
        return 1
    fi

    local hostname
    if ! hostname=$(ssh "$machine" "hostname"); then
        echo "$machine:$network - Failed to get hostname" >> $failures_file
        return 1
    fi

    local base_path="/opt/$network/chains"
    local sub_networks
    if ! sub_networks=$(ssh "$machine" "find $base_path -mindepth 1 -maxdepth 1 -type d ! -name 'lost+found' -exec basename {} \;"); then
        echo "$machine:$network - Failed to find sub-networks" >> $failures_file
        return 1
    fi

    for sub_network in $sub_networks; do
        local secret_key_path="$base_path/$sub_network/network/secret_ed25519"

        if ssh "$machine" "[ -f $secret_key_path ]"; then
            local peer_id
            if ! peer_id=$(ssh "$machine" "$genpeerid_path $secret_key_path"); then
                echo "$machine:$network - Failed to generate peer ID for $sub_network" >> $failures_file
                continue
            fi

            local backup_filename="${hostname}_${sub_network}_${peer_id}.secret_ed25519"
            if ! scp "$machine:$secret_key_path" "$backup_dir/$backup_filename"; then
                echo "$machine:$network - Failed to copy secret key for $sub_network" >> $failures_file
                continue
            fi

            echo "Backup completed for $sub_network on $machine."
        else
            echo "$machine:$network - Secret key file not found for $sub_network" >> $failures_file
        fi
    done
}

main() {
    check_dependencies

    local inventory_file="../inventory"
    local nodes_and_networks
    nodes_and_networks=$(get_proxmox_nodes_and_networks "$inventory_file")

    export genpeerid_url="https://github.com/rotkonetworks/genpeerid/releases/download/0.12.0/genpeerid"
    export genpeerid_path="/tmp/genpeerid"
    export backup_dir="./bootnode_backup"
    local failures_file="failures.tmp"

    mkdir -p "$backup_dir"
    > $failures_file

    export -f process_node
    export genpeerid_url genpeerid_path backup_dir failures_file

    echo "$nodes_and_networks" | tr ' ' '\n' | tr ':' ' ' | xargs -n 2 -P 10 bash -c 'process_node "$@"' _

    echo "All backups completed."

    if [[ -s $failures_file ]]; then
        echo "The following backups failed:"
        cat $failures_file
    else
        echo "All backups were successful."
    fi

    rm -f $failures_file
}

main
