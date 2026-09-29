# Day 08 teardown - Azure CLI
$rg = 'rg-lab-core-eus2'; $vm = 'vm-iis01'
az network nsg rule delete -g $rg --nsg-name nsg-app -n Allow-App01-to-IIS01-80
az vm delete -g $rg -n $vm --yes
az resource delete -g $rg -n "shutdown-computevm-$vm" --resource-type 'Microsoft.DevTestLab/schedules' 2>$null
az vm deallocate -g $rg -n vm-app01
az resource list -g $rg --query '[].{name:name,type:type}' -o table
