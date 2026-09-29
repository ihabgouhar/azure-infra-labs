# Day 04 - Az PowerShell (ssh-keygen -t rsa -b 4096 -f "$HOME\.ssh\azlab_rsa" first)
$rg = 'rg-lab-core-eus2'; $loc = 'eastus2'
$myip = (Invoke-RestMethod -Uri 'https://api.ipify.org').Trim()
$rule = New-AzNetworkSecurityRuleConfig -Name 'Allow-HTTP-MyIP' -Priority 100 -Direction Inbound -Access Allow `
         -Protocol Tcp -SourceAddressPrefix "$myip/32" -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange 80
$nsg = New-AzNetworkSecurityGroup -Name 'nsg-web' -ResourceGroupName $rg -Location $loc -SecurityRules $rule -Tag @{ day = '04' }
$vnet = Get-AzVirtualNetwork -Name 'vnet-lab-eus2' -ResourceGroupName $rg
(Get-AzVirtualNetworkSubnetConfig -Name 'snet-web' -VirtualNetwork $vnet).NetworkSecurityGroup = $nsg
$vnet | Set-AzVirtualNetwork | Out-Null
$pip = New-AzPublicIpAddress -Name 'pip-web01' -ResourceGroupName $rg -Location $loc -Sku Standard -AllocationMethod Static -Tag @{ day = '04' }
$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'snet-web' -VirtualNetwork (Get-AzVirtualNetwork -Name 'vnet-lab-eus2' -ResourceGroupName $rg)
$nic = New-AzNetworkInterface -Name 'vm-web01-nic' -ResourceGroupName $rg -Location $loc -SubnetId $subnet.Id -PublicIpAddressId $pip.Id -Tag @{ day = '04' }
$cred = New-Object System.Management.Automation.PSCredential ('ihabadmin', (ConvertTo-SecureString ' ' -AsPlainText -Force))
$vm = New-AzVMConfig -VMName 'vm-web01' -VMSize 'Standard_B1s' -SecurityType 'TrustedLaunch'
$vm = Set-AzVMOperatingSystem -VM $vm -Linux -ComputerName 'vm-web01' -Credential $cred -DisablePasswordAuthentication `
        -CustomData (Get-Content "$PSScriptRoot\cloud-init.yaml" -Raw)
$vm = Add-AzVMSshPublicKey -VM $vm -KeyData (Get-Content "$HOME\.ssh\azlab_rsa.pub" -Raw) -Path '/home/ihabadmin/.ssh/authorized_keys'
$vm = Set-AzVMSourceImage -VM $vm -PublisherName 'Canonical' -Offer 'ubuntu-24_04-lts' -Skus 'server' -Version 'latest'
$vm = Set-AzVMOSDisk -VM $vm -CreateOption FromImage -StorageAccountType 'StandardSSD_LRS'
$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id
New-AzVM -ResourceGroupName $rg -Location $loc -VM $vm -Tag @{ day = '04'; env = 'lab' }
