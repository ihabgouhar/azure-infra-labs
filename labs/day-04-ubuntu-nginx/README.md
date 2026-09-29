# Day 04: Ubuntu web server with SSH key + cloud-init (NSG locked to one IP)

> Lab build in my own subscription. Built via Azure portal, Azure CLI and Az PowerShell.

## Scenario
An architecture studio wants a small staging web server that only their office IP can view, with no password login and no admin port open to the internet.

## What I built
- `vm-web01`: Ubuntu 24.04, B1s, SSH-key login only, public IP `pip-web01` (Standard, static)
- **cloud-init** first-boot file that installs nginx and writes a home page (like unattend.xml + a startup script)
- `nsg-web` on `snet-web`: allow TCP 80 **from my IP only**; port 22 is not open

## Proof it works
| Test | Result |
|------|--------|
| `Invoke-WebRequest http://<pip>` from home | 200 + custom page |
| Same URL from a phone on cellular | times out |
| `Test-NetConnection <pip> -Port 22` | False |

Scripts: [cloud-init.yaml](scripts/cloud-init.yaml) · [build-azps.ps1](scripts/build-azps.ps1)

## Lessons learned
- *(Write 2–4 bullets in your own words. This is the part clients read most.)*
