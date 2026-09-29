# Day 08 teardown - Az PowerShell
$rg = 'rg-lab-core-eus2'; $vmName = 'vm-iis01'
Get-AzNetworkSecurityGroup -ResourceGroupName $rg -Name 'nsg-app' |
  Remove-AzNetworkSecurityRuleConfig -Name 'Allow-App01-to-IIS01-80' | Set-AzNetworkSecurityGroup | Out-Null
Remove-AzVM -ResourceGroupName $rg -Name $vmName -Force
Remove-AzResource -ResourceGroupName $rg -ResourceType 'Microsoft.DevTestLab/schedules' -ResourceName "shutdown-computevm-$vmName" -Force -ErrorAction SilentlyContinue
Stop-AzVM -ResourceGroupName $rg -Name 'vm-app01' -Force
Get-AzResource -ResourceGroupName $rg | Sort-Object ResourceType | Format-Table Name, ResourceType
