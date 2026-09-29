# Day 08 - Az PowerShell
$rg = 'rg-lab-core-eus2'; $loc = 'eastus2'; $vmName = 'vm-iis01'
$vnet   = Get-AzVirtualNetwork -Name 'vnet-lab-eus2' -ResourceGroupName $rg
$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'snet-app' -VirtualNetwork $vnet
$asgApp = Get-AzApplicationSecurityGroup -ResourceGroupName $rg -Name 'asg-app'
$ipcfg  = New-AzNetworkInterfaceIpConfig -Name 'ipconfig1' -Subnet $subnet -PrivateIpAddress '10.10.2.11' -ApplicationSecurityGroup $asgApp
$nic    = New-AzNetworkInterface -Name 'vm-iis01-nic' -ResourceGroupName $rg -Location $loc -IpConfiguration $ipcfg -Tag @{ day = '08' }

$cred = Get-Credential -UserName 'ihabadmin' -Message 'Local admin for vm-iis01'
$cfg  = New-AzVMConfig -VMName $vmName -VMSize 'Standard_B2s' -SecurityType 'TrustedLaunch'
$cfg  = Set-AzVMUefi -VM $cfg -EnableVtpm $true -EnableSecureBoot $true
$cfg  = Set-AzVMOperatingSystem -VM $cfg -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$cfg  = Set-AzVMSourceImage -VM $cfg -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2022-datacenter-azure-edition' -Version 'latest'
$cfg  = Set-AzVMOSDisk -VM $cfg -CreateOption FromImage -StorageAccountType 'StandardSSD_LRS' -DeleteOption 'Delete'
$cfg  = Add-AzVMNetworkInterface -VM $cfg -Id $nic.Id -DeleteOption 'Delete'
New-AzVM -ResourceGroupName $rg -Location $loc -VM $cfg -Tag @{ day = '08' }

# Run Command - before
(Invoke-AzVMRunCommand -ResourceGroupName $rg -VMName $vmName -CommandId 'RunPowerShellScript' `
  -ScriptString 'Get-WindowsFeature Web-Server | Select-Object Name, InstallState').Value[0].Message

# Custom Script Extension
$cmd = 'powershell -ExecutionPolicy Unrestricted -Command "Install-WindowsFeature Web-Server -IncludeManagementTools; Set-Content -Path C:\inetpub\wwwroot\index.html -Value (''<h1>'' + $env:COMPUTERNAME + '' - deployed by Custom Script Extension</h1>'')"'
Set-AzVMExtension -ResourceGroupName $rg -VMName $vmName -Location $loc -Name 'CustomScriptExtension' `
  -Publisher 'Microsoft.Compute' -ExtensionType 'CustomScriptExtension' -TypeHandlerVersion '1.10' `
  -ProtectedSettings @{ commandToExecute = $cmd }

# NSG rule 300 (below Deny 4000)
Get-AzNetworkSecurityGroup -ResourceGroupName $rg -Name 'nsg-app' |
  Add-AzNetworkSecurityRuleConfig -Name 'Allow-App01-to-IIS01-80' -Priority 300 -Direction Inbound -Access Allow `
    -Protocol Tcp -SourceAddressPrefix '10.10.2.10' -SourcePortRange '*' -DestinationAddressPrefix '10.10.2.11' -DestinationPortRange 80 |
  Set-AzNetworkSecurityGroup | Out-Null
