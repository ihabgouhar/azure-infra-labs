# Day 03: Windows Server 2022 VM with no public IP + Azure Bastion

> Lab build in my own subscription. Built via Azure portal, Azure CLI and Az PowerShell.

## Scenario
A 12-person accounting firm was hit by RDP brute-force at their old host. They want a Windows server that is **not reachable from the internet** but still easy for admins to manage.

## What I built
- `vm-app01`: Windows Server 2022 Datacenter Azure Edition, B2s, Trusted Launch, `snet-app`, static **10.10.2.10**, **no public IP**
- **Azure Bastion Developer** (free tier): RDP in the browser through the portal. No port 3389 is exposed.

## Proof it works
- VM has no public IP; `ipconfig` inside shows 10.10.2.10
- Bastion session opens the desktop
- `Test-NetConnection www.microsoft.com -Port 443` fails because new subnets have no default outbound internet

Scripts: [build-azps.ps1](scripts/build-azps.ps1)

## Cost control
Deallocate with `Stop-AzVM` (portal Stop). A shutdown from inside Windows keeps billing.

## Lessons learned
- *(Write 2–4 bullets in your own words. This is the part clients read most.)*
