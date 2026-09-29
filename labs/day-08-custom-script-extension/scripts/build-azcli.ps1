# Day 08 - Azure CLI (run in PowerShell)
$rg = 'rg-lab-core-eus2'; $loc = 'eastus2'; $vm = 'vm-iis01'
az vm create -g $rg -n $vm -l $loc `
  --image 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest' `
  --size Standard_B2s --security-type TrustedLaunch --enable-secure-boot true --enable-vtpm true `
  --vnet-name vnet-lab-eus2 --subnet snet-app --private-ip-address 10.10.2.11 `
  --public-ip-address '""' --nsg '""' --asgs asg-app `
  --storage-sku StandardSSD_LRS --os-disk-delete-option Delete --nic-delete-option Delete `
  --admin-username ihabadmin --tags day=08

# Run Command - before
az vm run-command invoke -g $rg -n $vm --command-id RunPowerShellScript `
  --scripts 'Get-WindowsFeature Web-Server | Select-Object Name, InstallState' --query 'value[0].message' -o tsv

# Custom Script Extension
@'
{ "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command \"Install-WindowsFeature Web-Server -IncludeManagementTools; Set-Content -Path C:\\inetpub\\wwwroot\\index.html -Value ('<h1>' + $env:COMPUTERNAME + ' - deployed by Custom Script Extension</h1>')\"" }
'@ | Set-Content -Path .\cse-iis.json
az vm extension set -g $rg --vm-name $vm --name CustomScriptExtension `
  --publisher Microsoft.Compute --version 1.10 --protected-settings '@cse-iis.json'

# NSG rule 300 (below Deny 4000)
az network nsg rule create -g $rg --nsg-name nsg-app -n Allow-App01-to-IIS01-80 --priority 300 `
  --direction Inbound --access Allow --protocol Tcp `
  --source-address-prefixes 10.10.2.10 --source-port-ranges '*' `
  --destination-address-prefixes 10.10.2.11 --destination-port-ranges 80
