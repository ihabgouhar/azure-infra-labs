# Day 06 - run INSIDE vm-app01 (PowerShell as Administrator), one section at a time

# --- Section 1: initialize F: and add test data
Get-Disk | Where-Object PartitionStyle -eq 'RAW' |
  Initialize-Disk -PartitionStyle GPT -PassThru |
  New-Partition -DriveLetter F -UseMaximumSize |
  Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Data' -Confirm:$false
New-Item F:\Clients -ItemType Directory
'Invoice 1001 - test data' | Set-Content F:\Clients\invoice-1001.txt

# --- Section 2: extend F: after the Azure-side expand
Update-HostStorageCache
Resize-Partition -DriveLetter F -Size (Get-PartitionSupportedSize -DriveLetter F).SizeMax

# --- Section 3: simulate the incident (after the snapshot)
Remove-Item F:\Clients\invoice-1001.txt

# --- Section 4: bring the restored clone online as G: and recover
$clone = Get-Disk | Where-Object IsOffline -eq $true
Set-Disk -Number $clone.Number -IsOffline $false
Set-Disk -Number $clone.Number -IsReadOnly $false
Get-Partition -DiskNumber $clone.Number | Where-Object Type -eq 'Basic' | Set-Partition -NewDriveLetter G
Copy-Item G:\Clients\invoice-1001.txt F:\Clients\

# --- Before teardown
Get-Partition -DriveLetter F,G | Get-Disk | Set-Disk -IsOffline $true
