
### To update the latest image

- [Ensure that you have the latest version of `devcontainer.json`.](FRONTDEV.md#2-configure-docker)
- Use the VSCode command picker with `Ctrl + Shift + P` and select "Dev Containers: Rebuild Container Without Cache".

### 2025/12/02
Add the optional `VHOSTS` environment variable to `devcontainer.json` to create environments.
The default value matches the configuration file and the examples explained in the documentation.

For example:
```
VHOSTS="studio:8081;cloud:8082;sandbox:8080"
```
With this configuration, you can access using https://sandbox.localhost:8080, https://studio.localhost:8081 and https://cloud.localhost:8082.

Remember that the port is used to redirect to the configured environment in the `_config.php` file, and the name is used to maintain the session in cookies.

- You can change the names, ports, and number of environments as you wish.
- You can set credentials for each environment as needed.
- The ports must match the `forwardPorts` property.

### 2025/07/24
Use a non-root user to avoid permission problems.

### 2025/07/10
Added SSL to avoid conflicts with third parties.

### 2025/07/04
Added a sandbox environment: [http://sandbox.localhost:8080] with the same configuration as the others.

### 2025/07/03
Some changes have been introduced to support two environments: Studio and Cloud. You can now access both environments simultaneously using the following links:
- Studio environment: [http://studio.localhost:8081]
- Cloud environment: [http://cloud.localhost:8082]

If you have previously configured Docker, review the configuration changes:
- [Add the additional port in `devcontainer.json`.](README.md#2-configure-docker)
- [Review the configuration in `_config.php`.](README.md#6-prepare-the-commerce-to-develop)

You can continue using the old configuration if you do not need this feature.
