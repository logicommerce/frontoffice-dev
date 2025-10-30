# LogiCommerce Front Office Dev Container

[For updates and latest changes, see NOTES.md](NOTES.md)


## 1. Preparing environment for Dev Containers

For detailed instructions, refer to the Visual Studio Code documentation:
<https://code.visualstudio.com/docs/devcontainers/containers>

## 2. Configure Docker

Ensure your system meets the system requirements for Dev Containers:
<https://code.visualstudio.com/docs/devcontainers/containers#_system-requirements>

## 3. Install the VSCode extension

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
  - commerces/
    - MyCommerce/
      - repo-xxx/  <- 'git clone https://git-codecommit.eu-west-1.amazonaws.com/v1/repos/repo-xxx' (xxx means a commerce id.)
    - Other commerces...
  - .devcontainer/
    - devcontainer.json  <- copy this json from below
  - workspace/
    (leave empty for now)
  - use-commerce.sh      <- copy this script from below 
```

`devcontainer.json`

```json
{
    "name": "Commerce",
    "image": "public.ecr.aws/logicommerce-studio/lc-frontoffice-development:latest",
    "initializeCommand": "docker pull public.ecr.aws/logicommerce-studio/lc-frontoffice-development:latest || echo \"Pull failed — falling back to cached image.\"",
    "workspaceFolder": "/local/workspace",
    "forwardPorts": [8080, 8081, 8082],
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
    ],
    "runArgs": ["--name", "lc-frontoffice-development"]
}
```

> [!WARNING]
> Only copy the file. You don't need to modify any variable like `${localWorkspaceFolder}.`


`use-commerce.sh`

A helper script to switch the active commerce for development. Download from here:

[use-commerce-sh (Linux)](examples/use-commerce.sh) / [use-commerce.bat (Windows)](examples/use-commerce.bat)

Run this script from the `projects` folder each time you want to work on a different commerce and rebuild your container.
You can adapt the script to your project structure, but make sure to respect the workspace folder structure and the creation of symbolic links.


## 5. Populate workspace folder

> [!IMPORTANT]
> Unless stated otherwise, all commands in this document should be run from the `projects` folder, outside the docker container.

```sh
cd workspace
ln -s /local/www www
ln -s /local/lc/fwk fwk
ln -s /local/lc/sdk sdk
ln -s /local/lc/plugins plugins
```

## 6. Prepare the commerce to develop

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
// COMMERCE CREDENTIALS
// +------------------------------------------------------+

// Studio development environment (https://studio.localhost:8081)
$appId = '{{APP_ID}}';
$appKey = '{{APP_KEY}}';
$commerceId = '{{COMMERCE_ID}}';
$commerceHost = $commerceId . ".studio.logicommerce.cloud";

// Cloud production environment (https://cloud.localhost:8082) 
// (Optional)
if (apache_request_headers()['X-ContainerEnv'] === 'CLOUD') {
  var_dump('Cloud environment credentials are required.');
  exit;
  // $appId = '{{CLOUD_APP_ID}}';
  // $appKey = '{{CLOUD_APP_KEY}}';
  // $commerceId = '{{CLOUD_COMMERCE_ID}}';
  // $commerceHost = '{{CLOUD_COMMERCE_HOST}}';
}

// Sandbox development environment (https://sandbox.localhost:8080)
// (Optional)
if (apache_request_headers()['X-ContainerEnv'] === 'SANDBOX') {
  var_dump('Sandbox environment credentials are required.');
  exit;
  // $appId = '{{SANDBOX_APP_ID}}';
  // $appKey = '{{SANDBOX_APP_KEY}}';
  // $commerceId = '{{SANDBOX_COMMERCE_ID}}';
  // $commerceHost = '{{SANDBOX_COMMERCE_HOST}}';
}

// +------------------------------------------------------+
// LOCAL Environment variables                            |
// +------------------------------------------------------+
define('DEVEL', true);
define('APP_ID', $appId);
define('APP_KEY', $appKey);
define('COMMERCE_ID', $commerceId);
define('COMMERCE_HOST', $commerceHost);
// Uncomment if you are not using HTTPS
//define('COMMERCE_PROTOCOL', 'https');

// assets
// Uncomment this line if you use PHARs
// define('CDN_ASSETS_CORE', 'https://assets-studio.logicommerce.cloud/core/{{ASSETS_CORE_VERSION}}');
define('CDN_ASSETS_PLUGINS', 'https://assets-studio.logicommerce.cloud/plugins');

// Enable to use CORE js from SITE project
// Comment out this line if you use PHARs
define('FWK_JS_VERSION', 'SITE');

// Adapt constants to the current environment
define('DEV_CONTAINER', getenv('DEV_CONTAINER'));
define('COMMERCE_STORE_URL', getenv('COMMERCE_STORE_URL'));
define('COMMERCE_PROTOCOL', getenv('COMMERCE_PROTOCOL'));
define('API_URL', getenv('API_URL'));
define('GEOLOCATION_API_URL', getenv('GEOLOCATION_API_URL'));
define('LMS_API_URL', getenv('LMS_API_URL'));
define('CDN_ASSETS_URL', getenv('CDN_ASSETS_URL'));
define('REDIS_HOST', getenv('REDIS_HOST'));
define('REDIS_PORT', getenv('REDIS_PORT'));
define('DATA_STORAGE_HOST', getenv('DATA_STORAGE_HOST'));
define('DATA_STORAGE_PORT', getenv('DATA_STORAGE_PORT'));

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


## 7. Select the commerce to develop

You can only work on 1 commerce at a time.

```sh
./use-commerce.sh commerces/MyCommerce/repo-xxx
```

## 8. Launch the project in VSCode

Open VSCode, select File > Open Folder... and pick your `projects` folder (the one containing `.devcontainer`).
Launch the command picker with `Ctrl + Shift + P` and select "Dev Containers: Reopen in container"

Wait for the docker image to get built and launched, it may take some minutes the first time.

## 9. Visit your commerce in the browser

The commerce is now available at [https://localhost:8081](https://localhost:8081).


# Switching to a different commerce 

Remember that you can only work on one commerce at a given time. To change the commerce, do the following:

## If you already have the commerce configured.

**Step 1:** Run this command from your 'projects' folder. (Outside docker)

```sh
./use-commerce.sh commerces/OtherCommerce/repo-xxx 
```

-  (xxx is some numeric commerce id.)

**Step 2:** Launch the VSCode command picker with `Ctrl + Shift + P` and select "Dev Containers: Rebuild Container".

Reload the browser page ([https://localhost:8081](https://localhost:8081)) and you should see the new commerce.


## If you are adding a new commerce

1. Create a new folder inside `commerces`. Clone the new commerce inside.

2. Repeat step 6 (Prepare the commerce to develop) and step 7 (Select the commerce to develop) from the previous section, choose the new commerce.

4. Launch the command picker with `Ctrl + Shift + P` and select "Dev Containers: Rebuild Container"

5. Reload the browser page [https://localhost:8081](https://localhost:8081).


# Additional notes

### Using PHAR files instead of 'sdk', 'fwk' and 'plugins' repos 

Inside `lc` folder, place the following the following `phar` files:

- sdk.phar
- fwk.phar
- plugins.phar

Then modify the `_settingsConfig.php` files to avoid using `phar` files (set all of them to `false`).

Also modify `_config.php` (see comments containing "if you use PHARs").

### Connect as root user to Docker

By default, a non-root user is used to avoid permission issues. However, you can also connect as root using an external terminal:

```bash
docker exec -it -u root lc-frontoffice-development /bin/bash
```