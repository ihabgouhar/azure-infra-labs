# Day 08 - Az PowerShell. Run one block at a time.
$rg = 'rg-lab-core-eus2'; $loc = 'eastus2'; $vmName = 'vm-iis01'

# Create the server (no public IP; disk + NIC deleted with the VM)
$subnet = Get-AzVirtualNetwork -Name 'vnet-lab-eus2' -ResourceGroupName $rg | Get-AzVirtualNetworkSubnetConfig -Name 'snet-app'
$nic  = New-AzNetworkInterface -Name 'vm-iis01-nic' -ResourceGroupName $rg -Location $loc -SubnetId $subnet.Id
$cred = Get-Credential -UserName 'ihabadmin' -Message 'Password for vm-iis01'
$vm = New-AzVMConfig -VMName $vmName -VMSize 'Standard_B2s' -SecurityType 'TrustedLaunch'
$vm = Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent
$vm = Set-AzVMSourceImage -VM $vm -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2022-datacenter-azure-edition' -Version 'latest'
$vm = Set-AzVMOSDisk -VM $vm -CreateOption FromImage -StorageAccountType 'StandardSSD_LRS' -DeleteOption 'Delete'
$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id -DeleteOption 'Delete'
New-AzVM -ResourceGroupName $rg -Location $loc -VM $vm -Tag @{ day = '08' }

# BEFORE check (expect "Available")
(Invoke-AzVMRunCommand -ResourceGroupName $rg -VMName $vmName -CommandId 'RunPowerShellScript' -ScriptString 'Get-WindowsFeature -Name Web-Server').Value[0].Message

# Install IIS with the Custom Script Extension
Set-AzVMExtension -ResourceGroupName $rg -VMName $vmName -Location $loc -Name 'InstallIIS' `
  -Publisher 'Microsoft.Compute' -ExtensionType 'CustomScriptExtension' -TypeHandlerVersion '1.10' `
  -Settings @{ commandToExecute = 'powershell -ExecutionPolicy Unrestricted -Command Install-WindowsFeature -Name Web-Server -IncludeManagementTools' }

# AFTER check (expect 200 + text)
(Invoke-AzVMRunCommand -ResourceGroupName $rg -VMName $vmName -CommandId 'RunPowerShellScript' `
  -ScriptString "Set-Content -Path C:\inetpub\wwwroot\index.html -Value 'Hello from vm-iis01 - built without RDP'; Invoke-WebRequest -Uri http://localhost -UseBasicParsing | Select-Object StatusCode, Content").Value[0].Message
