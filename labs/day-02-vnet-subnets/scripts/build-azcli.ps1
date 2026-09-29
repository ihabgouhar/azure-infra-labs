# Day 02 - Azure CLI (run in PowerShell)
$rg = 'rg-lab-core-eus2'
az network vnet create -g $rg -n vnet-lab-eus2 -l eastus2 --address-prefixes '10.10.0.0/16' `
  --subnet-name snet-web --subnet-prefixes '10.10.1.0/24' --tags day=02
az network vnet subnet create -g $rg --vnet-name vnet-lab-eus2 -n snet-app  --address-prefixes '10.10.2.0/24'
az network vnet subnet create -g $rg --vnet-name vnet-lab-eus2 -n snet-mgmt --address-prefixes '10.10.3.0/24'
az network vnet subnet list -g $rg --vnet-name vnet-lab-eus2 --query '[].{name:name,prefix:addressPrefix}' -o table
