# Day 08 - Azure CLI (typed in PowerShell). Run one block at a time.
$rg = 'rg-lab-core-eus2'; $vm = 'vm-iis01'

az vm create -g $rg -n $vm -l eastus2 `
  --image 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest' `
  --size Standard_B2s --vnet-name vnet-lab-eus2 --subnet snet-app `
  --public-ip-address '""' --nsg '""' --storage-sku StandardSSD_LRS `
  --os-disk-delete-option Delete --nic-delete-option Delete `
  --admin-username ihabadmin --tags day=08

# BEFORE check
az vm run-command invoke -g $rg -n $vm --command-id RunPowerShellScript `
  --scripts "Get-WindowsFeature -Name Web-Server" --query 'value[0].message' -o tsv

# Install IIS with the Custom Script Extension
'{ "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command Install-WindowsFeature -Name Web-Server -IncludeManagementTools" }' |
  Set-Content -Path .\install-iis.json
az vm extension set -g $rg --vm-name $vm --name CustomScriptExtension --extension-instance-name InstallIIS `
  --publisher Microsoft.Compute --version 1.10 --settings '@install-iis.json'

# AFTER check
az vm run-command invoke -g $rg -n $vm --command-id RunPowerShellScript `
  --scripts "Set-Content -Path C:\inetpub\wwwroot\index.html -Value 'Hello from vm-iis01 - built without RDP'; Invoke-WebRequest -Uri http://localhost -UseBasicParsing | Select-Object StatusCode, Content" `
  --query 'value[0].message' -o tsv
