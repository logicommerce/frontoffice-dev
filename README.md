# LogiCommerce Front Office Dev Container

## Prepare environment for Dev Containers

Visual Studio Code documentation:
<https://code.visualstudio.com/docs/devcontainers/containers>

### Configure Docker

<https://code.visualstudio.com/docs/devcontainers/containers#_system-requirements>

### Install VSCode extension

Required extension: [**Dev Containers**](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

## Initialize project

Create folder project.

```console
mkdir {yourCommerceProject}
cd {yourCommerceProject}
```

Clone repo to www:

```console
git clone {commerce repo url} www
```

Create `lc` folder

In this folder, you can put the phar files:

- sdk.phar
- fwk.phar
- plugins.phar

Create folder `.devcontainer`.

Inside the `.devcontainer` create `devcontainer.json` file:

```json
{
  "name": "Commerce",
  "image": "public.ecr.aws/b4h2l2b5/lc-frontoffice-development:latest",
  "workspaceFolder": "/local/www",
  "forwardPorts": [8081],
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
    "source=${localWorkspaceFolder}/www,target=/local/www,type=bind",
    "source=${localWorkspaceFolder}/lc,target=/local/lc,type=bind"
  ]
}
```

This devcontainer file will create an dev container environment with port 8888
exposed, It will mount `www` and `lc` folders.

## Commerce development configuration

### Config files

Put `_serviceConfig.php` and `_config.php` inside the `www` folder.

#### _serviceConfig.php

```php
<?php

define('CACHE_PATH', SITE_PHYSICAL_PATH . '/../cache');
define('LOG_PATH', SITE_PHYSICAL_PATH . '/../logs');

// +------------------------------------------------------+
// | SDK & FWK & Plugins path                             |
// +------------------------------------------------------+
define('SDK_PATH', '/local/lc');
define('FWK_PATH', '/local/lc');
define('PLUGINS_PATH', '/local/lc');
define('USE_PHARS', true);
define('USE_LC_SDK_PHAR', true);
define('USE_LC_FWK_PHAR', true);
define('USE_LC_PLUGINS_PHAR', true);

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
define('CDN_ASSETS_CORE', 'https://assets-studio.logicommerce.cloud/core/{{ASSETS_CORE_VERSION}}');
define('CDN_ASSETS_PLUGINS', 'https://assets-studio.logicommerce.cloud/plugins');

// Rewrite commerce host
define('COMMERCE_PROTOCOL', 'https');
define('COMMERCE_STORE_URL', 'http://localhost:8081');
define('COMMERCE_HOST', '{{COMMERCE_ID}}.studio.logicommerce.cloud');
define('CDN_ASSETS_COMMERCE', '/assets');

// Internal data storage with Redis
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

It is necessary replace all {{values}}

- {{COMMERCE_ID}}
- {{APP_ID}}
- {{APP_KEY}}
- {{ASSETS_CORE_VERSION}}

### Update composer

```console
composer update
```
