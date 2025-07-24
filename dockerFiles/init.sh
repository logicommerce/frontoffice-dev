#!/bin/bash

# Exit on error
set -e

LOCAL_PATH="/local"
LC_PATH="$LOCAL_PATH/lc"

# Git config
git config --global --add safe.directory "*"

# Check if LC path is mounted
if [ ! -d "$LC_PATH" ]; then
    echo "LC directory not found at $LC_PATH, make sure you have mounted the local directory correctly."
    exit 1
fi

function plugins {
    echo "[plugins] Updating Composer for all plugins"
    cd "$LC_PATH/plugins"
    for d in ComLogicommerce*; do
        echo "[plugins] Updating $d"
        cd "$d"
        if [ ! -f "composer.json" ]; then
            echo "No composer.json found in $d"
            cd ..
            continue
        fi
        composer update <<< Y
        cd ..
    done
    composer update <<< Y || true
}

function fwk {
    echo "[fwk] Updating framework"
    cd "$LC_PATH/fwk"
    composer update <<< Y || true
}

function sdk {
    echo "[sdk] Updating SDK"
    cd "$LC_PATH/sdk"
    composer update <<< Y || true
}

function www {
    echo "[www] Updating web root"
    cd "$LOCAL_PATH/www"
    composer update <<< Y || true
}

# Run all steps
sdk
fwk
plugins
www