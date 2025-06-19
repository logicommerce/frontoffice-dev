#!/bin/bash

# Exit on error
set -e

LOCAL_PATH="/local"
LC_PATH="$LOCAL_PATH/lc"

service apache2 start
service redis-server start

if [ ! -d "$LC_PATH" ]; then
    echo "LC directory not found at $LC_PATH, make sure you have mounted the local directory correctly."
    exit 1
fi

function plugins {
    export COMPOSER_ALLOW_SUPERUSER=1
        echo "Updating Composer for all plugins"
        cd $LC_PATH/plugins
        for d in ComLogicommerce*; do
                echo "Updating $d"
                cd $d
                if [ ! -f "composer.json" ]; then
                        echo "No composer.json found in $d"
                        cd ..
                        continue
                fi
                composer update <<< Y
                cd ..
        done
    echo 'plugins'
    cd $LC_PATH/plugins
    composer update <<< Y
}

function fwk {
    echo 'fwk'
    cd $LC_PATH/fwk
    composer update <<< Y
}

function sdk {
    echo 'sdk'
    cd $LC_PATH/sdk
    composer update <<< Y
}

function www {
    echo 'www'
    cd $LOCAL_PATH/www
    composer update <<< Y
}

sdk
fwk
plugins
www
