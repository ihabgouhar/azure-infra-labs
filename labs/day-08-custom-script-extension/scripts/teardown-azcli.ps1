# Day 08 teardown - Azure CLI (disk + NIC are deleted with the VM)
$rg = 'rg-lab-core-eus2'
az vm delete -g $rg -n vm-iis01 --yes
az resource delete -g $rg -n shutdown-computevm-vm-iis01 --resource-type 'Microsoft.DevTestLab/schedules' 2>$null
Remove-Item .\install-iis.json -ErrorAction SilentlyContinue
az resource list -g $rg --query '[].name' -o tsv
