# LogiCommerce Front Office Dev Container

## 1. Preparing environment for Dev Containers

For detailed instructions, refer to the Visual Studio Code documentation:
<https://code.visualstudio.com/docs/devcontainers/containers>

### 2. Configure Docker

Ensure your system meets the system requirements for Dev Containers:
<https://code.visualstudio.com/docs/devcontainers/containers#_system-requirements>

### 3. Install the VSCode extension

Required extension: **Dev Containers**
<https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers>

## 4. Project Initialization

Create this project folder structure (the folder can be in Documents or anywhere you want):

```console
- projects/
  - lc/
    - fwk/         <- 'git clone git@bitbucket.org:logicommerce/framework-php fwk'
    - sdk/         <- 'git clone git@bitbucket.org:logicommerce/sdk-php sdk'
    - plugins/     <- 'git clone git@bitbucket.org:logicommerce/plugins-php plugins'
    - update.sh    <- copy this script from below [1]
  - commerces/
    - MyCommerce
      - repo-xxx   <- `git clone https://git-codecommit.eu-west-1.amazonaws.com/v1/repos/repo-xxx`
    - Other commerces...
  - .devcontainer/
    - devcontainer.json  <- copy this json from below [2]
  - workspace
    (leave empty for now)
```

[1] `update.sh` script:
```sh
#!/bin/bash

localPath=$(pwd)

function plugins {
    export COMPOSER_ALLOW_SUPERUSER=1
        echo "Updating Composer for all plugins"
        cd $localPath/plugins
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
    cd $localPath/plugins
    composer update <<< Y
}

function fwk {
    echo 'fwk'
    cd $localPath/fwk
    composer update <<< Y
}

function sdk {
    echo 'sdk'
    cd $localPath/sdk
    composer update <<< Y
}

function www {
    echo 'www'
    cd $localPath/../www
    composer update <<< Y
}

sdk
fwk
plugins
www
cd $localPath
exit 0
```

[2] `devcontainer.json`

```json
{
    "name": "Commerce",
    "image": "public.ecr.aws/logicommerce-studio/lc-frontoffice-development",
    "workspaceFolder": "/local/workspace",
    "forwardPorts": [
        8081
    ],
    "customizations": {
        "vscode": {
            "extensions": [
                "xdebug.php-debug",
                "bmewburn.vscode-intelephense-client",
                "whatwedo.twig",
                "dbaeumer.vscode-eslint"
            ]
        }
    },
    "postStartCommand": "/start.sh",
    "mounts": [
        "source=${localWorkspaceFolder}/workspace,target=/local/workspace,type=bind",
        "source=${localWorkspaceFolder}/www,target=/local/www,type=bind",
        "source=${localWorkspaceFolder}/lc,target=/local/lc,type=bind"
    ]
}
```

## 5. Make `update.sh` executable

```sh
chmod +x lc/update.sh
```

## 6. Populate `workspace`

```sh
cd workspace
ln -s /local/www www
ln -s /local/lc/fwk fwk
ln -s /local/lc/sdk sdk
ln -s /local/lc/plugins plugins
```

## 7. Prepare the commerce to develop

Create a link for local assets:

```sh
ln -s /local/lc/fwk/assets commerces/MyCommerce/repo-xxx/assets/core
```

Inside the commerce folder (`commerces/MyCommerce/repo-xxx`), create the following files:

#### _serviceConfig.php

```php
<?php

define('CACHE_PATH', SITE_PHYSICAL_PATH . '/../cache');
define('LOG_PATH', SITE_PHYSICAL_PATH . '/../logs');

// +------------------------------------------------------+
// | SDK & FWK & Plugins path                             |
// +------------------------------------------------------+
define('SDK_PATH', '/local/lc/sdk');
define('FWK_PATH', '/local/lc/fwk');
define('PLUGINS_PATH', '/local/lc/plugins');
define('USE_PHARS', false);
define('USE_LC_SDK_PHAR', false);
define('USE_LC_FWK_PHAR', false);
define('USE_LC_PLUGINS_PHAR', false);

// +------------------------------------------------------+
// | Variables redefined in deploy                        |
// +------------------------------------------------------+
// set environment constants
define('API_TIMEOUT', 20); // in seconds
// Show API requets errors
define('THROW_CONNECTION_ERRORS', false);

```

#### _config.php

```php
<?php

require_once '_serviceConfig.php';

// +------------------------------------------------------+
// LOCAL Environment variables                            |
// +------------------------------------------------------+
define('DEVEL', true);

define('COMMERCE_ID', {{COMMERCE_ID}});

// API Credentials
define('APP_ID', '{{APP_ID}}');
define('APP_KEY', '{{APP_KEY}}');

// assets
// Uncomment this line if you use PHARs
// define('CDN_ASSETS_CORE', 'https://assets-studio.logicommerce.cloud/core/{{ASSETS_CORE_VERSION}}');

define('CDN_ASSETS_PLUGINS', 'https://assets-studio.logicommerce.cloud/plugins');

// Enable to use CORE js from SITE project
// Comment out this line if you use PHARs
define('FWK_JS_VERSION', 'SITE');

// Rewrite commerce host
define('COMMERCE_PROTOCOL', 'https');
define('COMMERCE_STORE_URL', 'http://localhost:8081');
define('COMMERCE_HOST', "$COMMERCE_ID.studio.logicommerce.cloud");
define('CDN_ASSETS_COMMERCE', '/assets');

// Internal data storage with Redis
define('REDIS_HOST', '127.0.0.1');
define('REDIS_PORT', 6379);
define('DATA_STORAGE_HOST', '127.0.0.1');
define('DATA_STORAGE_PORT', 6379);

// API connections
define('API_URL', 'http://api-studio.logicommerce.cloud');
define('API_URL_PORT', '');
define('GEOLOCATION_API_URL', 'https://locations.logicommerce.com');
define('GEOLOCATION_API_URL_PORT', '');
define('LMS_API_URL', 'https://lms.logicommerce.com');
define('LMS_API_URL_PORT', '');


// +------------------------------------------------------+
// | Default studio/cloud constants                       |
// +------------------------------------------------------+
define('CHARSET', 'utf-8');

// Project configuration
define('THEME_DEFAULT_VERSION', 'Responsive');
define('THEME_DEFAULT_MODE', 'bootstrap5');

// File that manage the error when the commerce can't even load a controller
define("ERROR_WITHOUT_CONTROLLER", SITE_LOAD_PATH . '/src/Core/Exceptions/ErrorWithoutController.php');

define('DATE_TIME_FORMATER_DEFAULT_DATE_TYPE', \IntlDateFormatter::SHORT);
define('DATE_TIME_FORMATER_DEFAULT_TIME_TYPE', \IntlDateFormatter::SHORT);
define('DATE_TIME_FORMATER_DEFAULT_CALENDAR_TYPE', \IntlDateFormatter::GREGORIAN);

define('VIEW_DOCUMENT_LAYOUT', 'layouts/viewDocument.html.twig');

define('PURCHASE_MINIMUM_AMOUNT', 0);

define('DEFAULT_ROUTE', [
    'status' => 200,
    'language' => 'es',
    'currency' => 'EUR',
    'theme' => [
        'layout' => 'default',
        'content' => 'default',
        'name' => 'default',
        'channel' => ''
    ]
]);

// +------------------------------------------------------+
// | Shop constants                                       |
// +------------------------------------------------------+
// User order actions file extension (default .png)
define('USER_ACTIONS_FILE_EXTENSION', '.svg');
// Basket default not found image
define('IMAGE_MISSING_BASKET_ITEM', 'not-found-basket.png');

```

Replace all instances of `{{values}}` with the appropriate values:

- {{COMMERCE_ID}}
- {{APP_ID}}
- {{APP_KEY}}
- {{ASSETS_CORE_VERSION}} (only if using PHARs)


## 8. Select the commerce to develop

You can only work on 1 commerce at a time.

```sh
ln -sfn commerces/MyCommerce/repo-xxx www
```

## 9. Launch the project in VSCode

Open VSCode, select File > Open Folder... and pick your `projects` folder (the one containing `.devcontainer`).
Launch the command picker with `Ctrl + Shift + P` and select "Dev Containers: Reopen in container"

Wait for the docker image to get built and launched, it may take some minutes the first time.

## 10. (Only when needed because of LC or WWW changes) Run `composer update`

From inside the Docker container (VSCode window), run this command:

```sh
/local/lc/update.sh
```

## 10. Visit your commerce in the browser

The commerce is now available at [http://localhost:8081](http://localhost:8081).


# Switching to a different commerce

Remember that you can only work on one commerce at a given time. To change the commerce, do the following:

1. (ONLY FOR CLONING A NEW COMMERCE) Create a new folder inside `commerces`. Clone the new commerce inside.

2. (ONLY FOR CLONING A NEW COMMERCE) Repeat step 7 (Prepare the commerce to develop) from the previous section.

3. (*ALWAYS*) Repeat step 8 (Select the commerce to develop) from the previous section, choose the new commerce.

4. (*ALWAYS*) Launch the command picker with `Ctrl + Shift + P` and select "Dev Containers: Rebuild Container"

5. (*ALWAYS*) Reload the browser page [http://localhost:8081](http://localhost:8081).


# Additional notes

### Using PHAR files instead of `sdk`, `fwk` and `plugins` repos 

Inside `lc` folder, place the following the following `phar` files:

- sdk.phar
- fwk.phar
- plugins.phar

Then modify the `_settingsConfig.php` files to avoid using `phar` files (set all of them to `false`).

Also modify `_config.php` (see comments containing "if you use PHARs").


### Possible troubles on first start

In some cases, redis fails on start. You can start redis manually with this following command:

```bash
service redis-server restart
```
