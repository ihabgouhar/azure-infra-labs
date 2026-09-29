# Day 05 - Azure CLI (run in PowerShell)
$rg = 'rg-lab-core-eus2'
az network asg create -g $rg -n asg-web -l eastus2 --tags day=05
az network asg create -g $rg -n asg-app -l eastus2 --tags day=05
# Put NICs in ASGs (NIC names looked up from the VMs)
$webNic = (az vm show -g $rg -n vm-web01 --query 'networkProfile.networkInterfaces[0].id' -o tsv).Split('/')[-1]
$appNic = (az vm show -g $rg -n vm-app01 --query 'networkProfile.networkInterfaces[0].id' -o tsv).Split('/')[-1]
$webCfg = az network nic ip-config list -g $rg --nic-name $webNic --query '[0].name' -o tsv
$appCfg = az network nic ip-config list -g $rg --nic-name $appNic --query '[0].name' -o tsv
az network nic ip-config update -g $rg --nic-name $webNic -n $webCfg --asgs asg-web
az network nic ip-config update -g $rg --nic-name $appNic -n $appCfg --asgs asg-app
# NSG + rules
az network nsg create -g $rg -n nsg-app -l eastus2 --tags day=05
az network nsg rule create -g $rg --nsg-name nsg-app -n Allow-Web-to-App-443 --priority 100 --direction Inbound --access Allow `
  --protocol Tcp --source-asgs asg-web --source-port-ranges '*' --destination-asgs asg-app --destination-port-ranges 443
az network nsg rule create -g $rg --nsg-name nsg-app -n Allow-BastionDev-RDP --priority 200 --direction Inbound --access Allow `
  --protocol Tcp --source-address-prefixes 168.63.129.16 --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 3389
az network nsg rule create -g $rg --nsg-name nsg-app -n Deny-VNet-Inbound --priority 4000 --direction Inbound --access Deny `
  --protocol '*' --source-address-prefixes VirtualNetwork --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges '*'
az network vnet subnet update -g $rg --vnet-name vnet-lab-eus2 -n snet-app --network-security-group nsg-app
