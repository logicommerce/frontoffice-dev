#!/bin/bash

# Exit on error
set -e

# Information message
echo "Visit https://github.com/logicommerce/frontoffice-dev for more information."

DEFAULT_VHOSTS="sandbox:8080;studio:8081;cloud:8082"
sudo /local/tmp/create-vhosts.sh "${VHOSTS:-$DEFAULT_VHOSTS}"

# Start services as root
echo "[entrypoint] Starting Apache and Redis..."
sudo service apache2 start
sudo service redis-server start

# Run the main logic script as devuser
echo "[entrypoint] Init workspace..."
/bin/bash -c "/init.sh"
