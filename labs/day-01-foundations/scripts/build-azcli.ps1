# Day 01 - Azure CLI (run in PowerShell). Install once: winget install Microsoft.AzureCLI
az login
az group create -n 'rg-lab-core-eus2' -l eastus2 --tags env=lab owner=ihab
az group show -n 'rg-lab-core-eus2' --query '{name:name,location:location,tags:tags}'
# Budget: easiest in the portal (Cost Management > Budgets > + Add, $20 monthly, alerts 50/80/100%)
