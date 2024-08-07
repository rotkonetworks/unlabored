#!/bin/bash

# Define the lists of hosts with updated entries
polkadot_primary_hosts=(
    "pso06" "pso07" "pso03" "pso04" "dot14" "pso16" "pso24" "pso26" "wnd14" "wnd23" 
    "ksm04" "ksm14" "dot23" "ksm24"
)
cumulus_primary_hosts=(
    "kbr13" "kbr24" "mine24" "mine26" "mint14" "mint23" "pbr13"
    "pbr23" "pbr26" "pch13" "pch23" "rpc-asset-hub-paseo-02" "wbr13" "wbr23"
    "wch13" "wch23" "wmint14" "wmint23" "wmint26" "wbr13" "wbr23"
    "wch13" "wch23" "wmint23" "kppl16" "kppl26"
)

polkadot_secondary_hosts=(
    "dot01" "dot02" "dot26" "ksm01" "ksm02" "ksm26" "wnd26"
)

cumulus_secondary_hosts=(
    "kbr26" "mine14" "mint26" "mint27" "pch26"
    "boot-asset-hub-paseo" "rpc-asset-hub-paseo-01" "wcore16" "wcore26" "wcore27"
    "wglu16" "wglu26" "wglu27" "wmint26" "wppl16"
    "wppl26" "wppl27" "wbr26" "wch26" "wcore16" "wcore26" "wcore27"
    "wglu16" "wglu26" "wglu27" "wmint26" "wppl16"
    "wppl26" "wppl27" "kppl26"
)

# Function to unpin a single host
unpin_host() {
    local host="$1"
    echo "Unpinning ${host}..."
    inv unpin "${host}"
}

# Function to concurrently unpin hosts
unpin_hosts_concurrently() {
    for host in "${@}"; do
        unpin_host "${host}" &
    done
    wait # Wait for all background jobs to finish
}

# Check for input argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <list_number>"
    echo "1: polkadot primary, 2: polkadot secondary, 3: cumulus primary, 4: cumulus secondary"
    exit 1
fi

# Process the input argument
case "$1" in
    1)
        unpin_hosts_concurrently "${polkadot_primary_hosts[@]}"
        ;;
    2)
        unpin_hosts_concurrently "${polkadot_secondary_hosts[@]}"
        ;;
    3)
        unpin_hosts_concurrently "${cumulus_primary_hosts[@]}"
        ;;
    4)
        unpin_hosts_concurrently "${cumulus_secondary_hosts[@]}"
        ;;
    *)
        echo "Invalid list number: $1"
        echo "1: Unfailed Hosts, 2: Failed Hosts"
        exit 2
        ;;
esac
