
### To update the latest image

Use the VSCode command picker with `Ctrl + Shift + P` and select "Dev Containers: Rebuild Container Without Cache".

### 2025/07/03
Some changes have been introduced to support two environments: studio and cloud.

You can access both environments at the same time using the following links:
- Studio environment: [http://studio.localhost:8081]
- Cloud environment: [http://cloud.localhost:8082]

If you have previously configured Docker, review the configuration changes:
- Add the additional port in `devcontainer.json`. [See README.md]
- Review the configuration in `_config.php`. [See README.md]

You can continue using the old configuration if you do not need this feature.
