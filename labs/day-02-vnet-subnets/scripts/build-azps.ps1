# Day 02 - Az PowerShell
$rg = 'rg-lab-core-eus2'
$web  = New-AzVirtualNetworkSubnetConfig -Name 'snet-web'  -AddressPrefix '10.10.1.0/24'
$app  = New-AzVirtualNetworkSubnetConfig -Name 'snet-app'  -AddressPrefix '10.10.2.0/24'
$mgmt = New-AzVirtualNetworkSubnetConfig -Name 'snet-mgmt' -AddressPrefix '10.10.3.0/24'
New-AzVirtualNetwork -Name 'vnet-lab-eus2' -ResourceGroupName $rg -Location 'eastus2' `
  -AddressPrefix '10.10.0.0/16' -Subnet $web,$app,$mgmt -Tag @{ day = '02' }
