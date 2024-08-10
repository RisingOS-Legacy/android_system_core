#!/bin/sh
set -e

SWAP_COUNT=$1
SWAP_FILE="/data/swap/swapfile"

if [ "$#" -ne 1 ]; then
    echo "Usage: ram_boost.sh <swap_size_in_gb>"
    exit 1
fi

while true; do
    if [ -e "$SWAP_FILE" ]; then
        echo "Disabling existing swap..."
        if ! swapoff "$SWAP_FILE"; then
            echo "Failed to disable swap. Continuing..."
        fi
        echo "Removing existing swap file..."
        if ! rm -f "$SWAP_FILE"; then
            echo "Failed to delete swap file. Continuing..."
        fi
    else
        echo "No existing swap file found, skipping swapoff."
    fi
    if [ ! -d "/data/swap/" ]; then
        echo "Creating swap directory..."
        if ! mkdir -p "/data/swap/"; then
            echo "Failed to create swap directory. Exiting."
            exit 1
        fi
    fi
    echo "Creating swap file of size ${SWAP_SIZE_MB}MB..."
    if ! dd if=/dev/zero of="$SWAP_FILE" bs=1073741824 count="$SWAP_COUNT"; then
        echo "Failed to create swap file. Continuing..."
        sleep 10
        continue
    fi
    echo "Setting up swap space..."
    if ! mkswap "$SWAP_FILE"; then
        echo "Failed to set up swap space. Continuing..."
        sleep 10
        continue
    fi
    echo "Enabling swap..."
    if ! swapon "$SWAP_FILE" -p 32758; then
        echo "Failed to enable swap. Continuing..."
        sleep 10
        continue
    fi
    echo "Swap setup complete. Sleeping before next check..."
    break
done
