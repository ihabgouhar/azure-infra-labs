# Day 08: Custom Script Extension + Run Command (install IIS without RDP)

> Lab build in my own subscription. Built via Azure portal, Azure CLI and Az PowerShell.

## Scenario
A property-management company's policy says nobody RDPs into a server to build it. Every build step must be repeatable and logged. They need a Windows web server with IIS and a default page, deployed remotely.

## What I built
- `vm-iis01`: Windows Server 2022, B2s, `snet-app`, static 10.10.2.11, in `asg-app`, no public IP, auto-shutdown 23:00 Eastern
- **Run Command** to check state remotely (IIS "Available" → "Installed")
- **Custom Script Extension** to install IIS + deploy `index.html`, delivered through the VM agent (168.63.129.16), so it works on a subnet with **no internet**
- NSG rule 300 `Allow-App01-to-IIS01-80` (10.10.2.10 → 10.10.2.11 TCP 80), below the Deny-VNet rule 4000

## Design notes
| Tool | Like on-prem | Use it for |
|------|--------------|------------|
| Run Command | PsExec / Invoke-Command | One-off checks and fixes |
| Custom Script Extension | GPO startup script / SCCM package | Repeatable build steps, reported in Azure |

The portal's Extensions wizard requires a script in a Storage account, which a private subnet can't reach. So the portal method uses **Deploy a custom template** ([cse-template.json](scripts/cse-template.json)).

## Proof it works
| Test | Before | After |
|------|--------|-------|
| `Get-WindowsFeature Web-Server` (Run Command) | Available | Installed |
| vm-app01 → 10.10.2.11:80 | blocked (rule 4000) | page returned (rule 300) |
| CSE status | n/a | Provisioning succeeded |

Scripts: [build-azcli.ps1](scripts/build-azcli.ps1) · [build-azps.ps1](scripts/build-azps.ps1) · [teardown-azcli.ps1](scripts/teardown-azcli.ps1) · [teardown-azps.ps1](scripts/teardown-azps.ps1)

## Lessons learned
- *(Write 2–4 bullets in your own words. This is the part clients read most.)*
