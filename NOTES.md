
### To update the latest image

- [Ensure that you have the latest version of `devcontainer.json`.](README.md#2-configure-docker)
- Use the VSCode command picker with `Ctrl + Shift + P` and select "Dev Containers: Rebuild Container Without Cache".

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
