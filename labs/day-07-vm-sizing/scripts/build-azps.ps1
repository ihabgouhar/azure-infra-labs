# Day 07 build - Az PowerShell
$rg = 'rg-lab-core-eus2'; $loc = 'eastus2'; $vmName = 'vm-app01'
Start-AzVM -ResourceGroupName $rg -Name $vmName
Get-AzVMSize -ResourceGroupName $rg -VMName $vmName | Where-Object Name -like 'Standard_B*' |
  Format-Table Name, NumberOfCores, MemoryInMB

# Resize up (reboots)
$vm = Get-AzVM -ResourceGroupName $rg -Name $vmName
$vm.HardwareProfile.VmSize = 'Standard_B2ms'
Update-AzVM -ResourceGroupName $rg -VM $vm

# Deallocate (default for Stop-AzVM; -StayProvisioned would keep billing)
Stop-AzVM -ResourceGroupName $rg -Name $vmName -Force
(Get-AzVM -ResourceGroupName $rg -Name $vmName -Status).Statuses[1].DisplayStatus
Start-AzVM -ResourceGroupName $rg -Name $vmName

# Auto-shutdown 23:00 Eastern
foreach ($v in 'vm-app01','vm-web01') {
  $props = @{
    status = 'Enabled'; taskType = 'ComputeVmShutdownTask'
    dailyRecurrence = @{ time = '2300' }; timeZoneId = 'Eastern Standard Time'
    targetResourceId = (Get-AzVM -ResourceGroupName $rg -Name $v).Id
    notificationSettings = @{ status = 'Enabled'; timeInMinutes = 30; emailRecipient = '<your-email>'; notificationLocale = 'en' }
  }
  New-AzResource -ResourceGroupName $rg -Location $loc -ResourceType 'Microsoft.DevTestLab/schedules' `
    -ResourceName "shutdown-computevm-$v" -Properties $props -Tag @{ day = '07' } -Force
}

# Resize back
$vm = Get-AzVM -ResourceGroupName $rg -Name $vmName
$vm.HardwareProfile.VmSize = 'Standard_B2s'
Update-AzVM -ResourceGroupName $rg -VM $vm

# Cost by resource, month to date
$scope = "/subscriptions/$((Get-AzContext).Subscription.Id)/resourceGroups/$rg"
$grp = New-AzCostManagementQueryGroupingObject -Name 'ResourceId' -Type 'Dimension'
$res = Invoke-AzCostManagementQuery -Scope $scope -Timeframe MonthToDate -Type ActualCost `
  -DatasetAggregation @{ totalCost = @{ name = 'Cost'; function = 'Sum' } } -DatasetGrouping $grp
$res.Row | ForEach-Object { [pscustomobject]@{ Cost = [math]::Round([double]$_[0],2); Resource = ($_[1] -split '/')[-1] } } |
  Sort-Object Cost -Descending | Format-Table
