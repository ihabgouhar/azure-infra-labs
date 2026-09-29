# Day 07 build - Azure CLI (run in PowerShell)
$rg = 'rg-lab-core-eus2'; $vm = 'vm-app01'
az vm start -g $rg -n $vm

# Sizes available on current hardware
az vm list-vm-resize-options -g $rg -n $vm `
  --query "[?starts_with(name,'Standard_B')].{name:name,cores:numberOfCores,memMB:memoryInMB}" -o table

# Resize up (reboots)
az vm resize -g $rg -n $vm --size Standard_B2ms

# Deallocate (NOT 'az vm stop', which keeps billing)
az vm deallocate -g $rg -n $vm
az vm get-instance-view -g $rg -n $vm --query 'instanceView.statuses[1].displayStatus' -o tsv
az vm start -g $rg -n $vm

# Auto-shutdown 23:00 Eastern (az takes UTC; then switch the schedule to Eastern for DST)
$email = '<your-email>'
foreach ($v in 'vm-app01','vm-web01') {
  az vm auto-shutdown -g $rg -n $v --time 0300 --email $email
  $schedId = az resource show -g $rg -n "shutdown-computevm-$v" `
    --resource-type 'Microsoft.DevTestLab/schedules' --query id -o tsv
  az resource update --ids $schedId `
    --set properties.timeZoneId='Eastern Standard Time' properties.dailyRecurrence.time='2300' tags.day='07'
}

# Resize back
az vm resize -g $rg -n $vm --size Standard_B2s

# Cost by resource, month to date (REST via az rest)
$sub = az account show --query id -o tsv
@'
{ "type": "ActualCost", "timeframe": "MonthToDate",
  "dataset": { "granularity": "None",
    "aggregation": { "totalCost": { "name": "Cost", "function": "Sum" } },
    "grouping": [ { "type": "Dimension", "name": "ResourceId" } ] } }
'@ | Set-Content -Path .\costquery.json
az rest --method post `
  --url "https://management.azure.com/subscriptions/$sub/resourceGroups/$rg/providers/Microsoft.CostManagement/query?api-version=2023-03-01" `
  --body '@costquery.json' --query 'properties.rows' -o json
