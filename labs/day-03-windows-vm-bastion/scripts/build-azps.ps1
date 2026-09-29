# Day 03 - Az PowerShell
$rg = 'rg-lab-core-eus2'; $loc = 'eastus2'
$vnet   = Get-AzVirtualNetwork -Name 'vnet-lab-eus2' -ResourceGroupName $rg
$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'snet-app' -VirtualNetwork $vnet
$nic = New-AzNetworkInterface -Name 'vm-app01-nic' -ResourceGroupName $rg -Location $loc `
        -SubnetId $subnet.Id -PrivateIpAddress '10.10.2.10'
$cred = Get-Credential -Message 'Local admin for vm-app01'
$vm = New-AzVMConfig -VMName 'vm-app01' -VMSize 'Standard_B2s' -SecurityType 'TrustedLaunch'
$vm = Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName 'vm-app01' -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm = Set-AzVMSourceImage -VM $vm -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' `
        -Skus '2022-datacenter-azure-edition' -Version 'latest'
$vm = Set-AzVMOSDisk -VM $vm -CreateOption FromImage -StorageAccountType 'StandardSSD_LRS'
$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id
New-AzVM -ResourceGroupName $rg -Location $loc -VM $vm -Tag @{ day = '03'; env = 'lab' }
# Connect: portal > vm-app01 > Connect > Bastion (Deploy Bastion Developer the first time)
