# Day 01 - Az PowerShell. Install once: Install-Module Az -Scope CurrentUser
Connect-AzAccount
New-AzResourceGroup -Name 'rg-lab-core-eus2' -Location 'eastus2' -Tag @{ env = 'lab'; owner = 'ihab' }
Get-AzResourceGroup -Name 'rg-lab-core-eus2' | Select-Object ResourceGroupName, Location, Tags
# Budget ($20/month, email alerts) - replace the email address
New-AzConsumptionBudget -Name 'budget-lab-20' -Amount 20 -Category Cost -TimeGrain Monthly `
  -StartDate (Get-Date -Day 1).Date -ContactEmail '<your-email>' -NotificationKey 'at80' `
  -NotificationThreshold 80 -NotificationEnabled
