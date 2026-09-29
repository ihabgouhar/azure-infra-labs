# Day 01: Resource groups, naming, tags and a budget alert

> Lab build in my own subscription. Built via Azure portal, Azure CLI and Az PowerShell.

## Scenario
A 25-person accounting firm opened its first Azure subscription and needs a naming standard, tagging, the admin tools, and a spending alarm before anything gets built.

## What I built
- Resource group `rg-lab-core-eus2` (East US 2) with tags
- Azure CLI + Az PowerShell installed on a Windows workstation
- A **$20/month budget** with email alerts at 50%, 80% and 100%

## Proof it works
- `az group show -n rg-lab-core-eus2` / `Get-AzResourceGroup` shows the tags
- Cost Management > Budgets shows the budget and alert thresholds

Scripts: [build-azcli.ps1](scripts/build-azcli.ps1) · [build-azps.ps1](scripts/build-azps.ps1)

## Lessons learned
- *(Write 2–4 bullets in your own words. This is the part clients read most.)*
