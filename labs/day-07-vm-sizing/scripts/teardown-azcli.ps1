# Day 07 teardown - Azure CLI (auto-shutdown intentionally kept)
$rg = 'rg-lab-core-eus2'
az vm show -g $rg -n vm-app01 --query 'hardwareProfile.vmSize' -o tsv   # expect Standard_B2s
az vm deallocate -g $rg -n vm-app01
az vm deallocate -g $rg -n vm-web01
# Optional: az vm auto-shutdown -g $rg -n vm-app01 --off
az vm list -g $rg -d --query '[].{name:name,size:hardwareProfile.vmSize,power:powerState}' -o table
