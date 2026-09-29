# Day 06: Managed disks (add, expand online, snapshot, restore)

> Lab build in my own subscription. Built via portal, Azure CLI and Az PowerShell.

## Scenario
A small accounting firm's file/app server (`vm-app01`, Windows Server 2022) needs client data on a separate drive, more space during tax season without downtime, and proof for their auditor that a deleted file can be recovered from a point-in-time copy.

## What I built
- `disk-app01-data01`: Standard SSD data disk, LUN 0, ReadOnly host caching, 8 GiB, then expanded to 16 GiB **online**
- `snap-app01-data01`: incremental snapshot of the data disk
- `disk-app01-restore01`: new disk created from the snapshot, attached at LUN 1 and mounted as G:

## Design notes
- Data goes on its own managed disk (F:), never on the temporary disk (D:), which is wiped on deallocate.
- Disks are created in the same availability zone as the VM (scripts read the VM's zone).
- Incremental snapshots bill only for changed blocks. They are crash-consistent, not a substitute for Azure Backup.

## Steps (summary)
1. Create + attach an 8 GiB data disk; initialize GPT/NTFS as F: in Windows.
2. Expand to 16 GiB with the VM running, then `Resize-Partition` in Windows.
3. Take an incremental snapshot, then delete a test file.
4. Create a disk from the snapshot, attach at LUN 1, clear the **disk signature collision** (`Set-Disk -IsOffline $false`), mount as G:, and copy the file back.

Scripts: [build-azcli.ps1](scripts/build-azcli.ps1) · [build-azps.ps1](scripts/build-azps.ps1) · [in-guest.ps1](scripts/in-guest.ps1)

## Proof it works
| Test | Before | After |
|------|--------|-------|
| F: size in Windows | ~8 GB | ~16 GB (no reboot) |
| `F:\Clients\invoice-1001.txt` | deleted | restored from G: (snapshot copy) |
| Restored disk size | n/a | 16 GiB, proving the snapshot was taken after the expand |

Screenshots: `screenshots/01-disks-blade.png`, `screenshots/02-disk-management.png`

## Teardown
[teardown-azcli.ps1](scripts/teardown-azcli.ps1) · [teardown-azps.ps1](scripts/teardown-azps.ps1). Detach → delete restore disk → snapshot → data disk → deallocate VM.

## Lessons learned / gotchas
- *(Write 3–4 bullets in your own words, e.g. the signature-collision surprise, zone mismatch errors, Windows not seeing new space until the partition is extended.)*

## Cost
Pennies: Standard SSD 8–16 GiB prorated + incremental snapshot + ~1 hr of B2s.
