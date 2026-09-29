# Day 06 teardown - Azure CLI (keeps RG, VNet, Bastion, VMs)
$rg = 'rg-lab-core-eus2'; $vm = 'vm-app01'
az vm disk detach -g $rg --vm-name $vm --name 'disk-app01-restore01'
az vm disk detach -g $rg --vm-name $vm --name 'disk-app01-data01'
az disk delete -g $rg -n 'disk-app01-restore01' --yes
az snapshot delete -g $rg -n 'snap-app01-data01'
az disk delete -g $rg -n 'disk-app01-data01' --yes
az vm deallocate -g $rg -n $vm
az resource list -g $rg --query '[].{name:name,type:type}' -o table
