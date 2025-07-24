#!/bin/bash

# Exit on error
set -e

# Information message
echo "Visit https://github.com/logicommerce/frontoffice-dev for more information."

# Start services as root
echo "[entrypoint] Starting Apache and Redis..."
sudo service apache2 start
sudo service redis-server start

# Run the main logic script as devuser
echo "[entrypoint] Init workspace..."
/bin/bash -c "/init.sh"
