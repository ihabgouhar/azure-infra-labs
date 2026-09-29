# Day 06 build - Azure CLI (run in PowerShell)
$rg = 'rg-lab-core-eus2'; $loc = 'eastus2'; $vm = 'vm-app01'
az vm start -g $rg -n $vm
$zone = az vm show -g $rg -n $vm --query 'zones[0]' -o tsv
$zoneArg = @(); if ($zone) { $zoneArg = @('--zone', $zone) }

# 1. Data disk
az disk create -g $rg -n 'disk-app01-data01' -l $loc `
  --size-gb 8 --sku StandardSSD_LRS --tags day=06 @zoneArg
az vm disk attach -g $rg --vm-name $vm --name 'disk-app01-data01' --lun 0 --caching ReadOnly
# >>> run in-guest.ps1 section 1 inside the VM

# 2. Expand online
az disk update -g $rg -n 'disk-app01-data01' --size-gb 16
# >>> run in-guest.ps1 section 2

# 3. Snapshot
$diskId = az disk show -g $rg -n 'disk-app01-data01' --query id -o tsv
az snapshot create -g $rg -n 'snap-app01-data01' -l $loc --source $diskId --incremental true --tags day=06
az snapshot show -g $rg -n 'snap-app01-data01' --query 'completionPercent' -o tsv
# >>> run in-guest.ps1 section 3

# 4. Restore to new disk + attach
$snapId = az snapshot show -g $rg -n 'snap-app01-data01' --query id -o tsv
az disk create -g $rg -n 'disk-app01-restore01' -l $loc `
  --source $snapId --sku StandardSSD_LRS --tags day=06 @zoneArg
az vm disk attach -g $rg --vm-name $vm --name 'disk-app01-restore01' --lun 1 --caching ReadOnly
# >>> run in-guest.ps1 section 4
