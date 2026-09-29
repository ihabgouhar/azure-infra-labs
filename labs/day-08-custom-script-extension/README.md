# Day 08: Install IIS without RDP (Run Command + Custom Script Extension)

> Lab build in my own subscription. Built via Azure portal, Azure CLI and Az PowerShell.

## Scenario
A company's policy says admins may not RDP into servers to build them. They need a Windows web server with IIS installed remotely and a way to check servers without logging in.

## What I built
- `vm-iis01`: Windows Server 2022, Standard_B2s, subnet `snet-app`, **no public IP**
- **Run Command** to check the server remotely (like PsExec)
- **Custom Script Extension** `InstallIIS` to install IIS (like a GPO startup script, repeatable and logged in Azure)

## Design notes
| Tool | On-prem equivalent | Used for |
|------|--------------------|----------|
| Run Command | PsExec / Invoke-Command | Quick checks and one-off fixes |
| Custom Script Extension | GPO startup script | Repeatable build steps |

Both work through the Azure VM Agent, so the server needs **no public IP and no internet**. In the portal, the extension is deployed with **Deploy a custom template** ([cse-template.json](scripts/cse-template.json)) because the normal extension wizard needs a script stored in a Storage account.

## Proof it works
| Check (via Run Command) | Before | After |
|-------------------------|--------|-------|
| `Get-WindowsFeature Web-Server` | Available | Installed |
| `Invoke-WebRequest http://localhost` | no web server | 200 + "Hello from vm-iis01 - built without RDP" |
| Extension status | none | Provisioning succeeded |

Scripts: [build-azps.ps1](scripts/build-azps.ps1) · [build-azcli.ps1](scripts/build-azcli.ps1) · [teardown-azps.ps1](scripts/teardown-azps.ps1) · [teardown-azcli.ps1](scripts/teardown-azcli.ps1)

## Lessons learned
- *(Write 2-4 bullets in your own words. This is the part clients read most.)*
