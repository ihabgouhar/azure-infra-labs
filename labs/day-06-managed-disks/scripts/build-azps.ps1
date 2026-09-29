# Day 06 build - Az PowerShell
$rg = 'rg-lab-core-eus2'; $loc = 'eastus2'; $vmName = 'vm-app01'
Start-AzVM -ResourceGroupName $rg -Name $vmName
$zone = (Get-AzVM -ResourceGroupName $rg -Name $vmName).Zones

# 1. Data disk
$cfg = New-AzDiskConfig -Location $loc -CreateOption Empty -DiskSizeGB 8 `
  -SkuName StandardSSD_LRS -Tag @{ day = '06' }
if ($zone) { $cfg.Zones = $zone }
$d1 = New-AzDisk -ResourceGroupName $rg -DiskName 'disk-app01-data01' -Disk $cfg
$vm = Get-AzVM -ResourceGroupName $rg -Name $vmName
$vm = Add-AzVMDataDisk -VM $vm -Name 'disk-app01-data01' -ManagedDiskId $d1.Id -CreateOption Attach -Lun 0 -Caching ReadOnly
Update-AzVM -ResourceGroupName $rg -VM $vm

# 2. Expand online
$d1 = Get-AzDisk -ResourceGroupName $rg -DiskName 'disk-app01-data01'
$d1.DiskSizeGB = 16
Update-AzDisk -ResourceGroupName $rg -DiskName $d1.Name -Disk $d1

# 3. Snapshot
$snapCfg = New-AzSnapshotConfig -SourceUri $d1.Id -Location $loc -CreateOption Copy -Incremental -Tag @{ day = '06' }
New-AzSnapshot -ResourceGroupName $rg -SnapshotName 'snap-app01-data01' -Snapshot $snapCfg

# 4. Restore + attach
$snap = Get-AzSnapshot -ResourceGroupName $rg -SnapshotName 'snap-app01-data01'
$rCfg = New-AzDiskConfig -Location $loc -CreateOption Copy -SourceResourceId $snap.Id -SkuName StandardSSD_LRS -Tag @{ day = '06' }
if ($zone) { $rCfg.Zones = $zone }
$d2 = New-AzDisk -ResourceGroupName $rg -DiskName 'disk-app01-restore01' -Disk $rCfg
$vm = Get-AzVM -ResourceGroupName $rg -Name $vmName
$vm = Add-AzVMDataDisk -VM $vm -Name 'disk-app01-restore01' -ManagedDiskId $d2.Id -CreateOption Attach -Lun 1 -Caching ReadOnly
Update-AzVM -ResourceGroupName $rg -VM $vm
