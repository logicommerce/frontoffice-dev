#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-commerce>"
    exit 1
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")
COMMERCE_DIR=$(realpath "$1")
cd "$SCRIPT_DIR"

if [ ! -d "$COMMERCE_DIR" ]; then
    echo "Error: Directory $COMMERCE_DIR does not exist"
    exit 1
fi
if [ ! -f "$COMMERCE_DIR/index.php" ]; then
    echo "Make sure you have chosen a valid commerce directory."
    exit 1
fi

ln -sfn $COMMERCE_DIR www

# Create assets symlink only if not using PHARs
if [ -d "$SCRIPT_DIR/lc/fwk" ]; then
    ln -sfn /local/lc/fwk/assets www/assets/core
fi