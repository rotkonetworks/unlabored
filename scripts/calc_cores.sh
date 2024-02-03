#!/bin/bash

# Check if a filename is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

# Filename is the first argument
filename=$1

# Calculate the sum of cores
awk '!/^[[:space:]]*#/ && (/^cores: [0-9]+/ || /^[[:space:]]+cores: [0-9]+/) {sum += $2} END {print sum}' $filename
