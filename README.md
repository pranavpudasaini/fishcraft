### Fishcraft: Minecraft Server on Azure

#### Instructions:

1. Clone the repo

```bash
git clone git@github.com:pranavpudasaini/fishcraft
```

2. Set the required Terraform variables

```
paisa_bachau_username = "YOUR_AZURE_AUTOMATION_USERNAME/ACCOUNT"
and paisa_bachau_password = "YOUR_AZURE_AUTOMATION_PASSWORD/SECRET" 
```

3. Setup and configure `azcli`

```bash
az cli --use-device-code
```


4. To deploy the infrastructure


```bash
make deploy
```

5. To destroy the infrastructure

```bash
make destroy
```
