# Day 02: VNet with web / app / mgmt subnets

> Lab build in my own subscription. Built via Azure portal, Azure CLI and Az PowerShell.

## Scenario
The firm is moving line-of-business servers to Azure and needs a tiered network: web, app and management subnets with room to grow.

## What I built
| Name | Address space |
|------|---------------|
| `vnet-lab-eus2` | 10.10.0.0/16 |
| `snet-web` | 10.10.1.0/24 |
| `snet-app` | 10.10.2.0/24 |
| `snet-mgmt` | 10.10.3.0/24 |

Built in the portal first, deleted, then rebuilt identically with the CLI.

## Design notes
A subnet works like a VLAN. Azure reserves 5 IPs in every subnet (first 4 + last), so a /24 gives 251 usable addresses.

## Proof it works
`az network vnet subnet list` / `Get-AzVirtualNetworkSubnetConfig` shows the 3 subnets and prefixes.

Scripts: [build-azcli.ps1](scripts/build-azcli.ps1) · [build-azps.ps1](scripts/build-azps.ps1)

## Lessons learned
- *(Write 2–4 bullets in your own words. This is the part clients read most.)*
