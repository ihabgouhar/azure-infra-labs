# Day 07: VM sizing (resize, stop vs deallocate, auto-shutdown, Cost Analysis)

> Lab build in my own subscription. Built via portal, Azure CLI and Az PowerShell.

## Scenario
An accounting firm's app server is slow during tax season, and the bill didn't drop even though staff "shut it down" nightly from the Start menu. They want it scaled up for busy weeks and back down after, a guaranteed 11 PM shutdown, and a view of where the money goes.

## What I built / changed
- Resized `vm-app01` **B2s → B2ms → B2s** (4 GB → 8 GB RAM and back)
- Showed the **Stopped vs Stopped (deallocated)** billing difference
- Auto-shutdown schedules `shutdown-computevm-vm-app01` / `-vm-web01` at **23:00 Eastern** with 30-min email warning
- Month-to-date cost by resource via Cost Analysis, the Cost Management REST API (`az rest`) and `Invoke-AzCostManagementQuery`

## Design notes
| Action | Compute billed? | Temp disk D: | Dynamic IPs |
|--------|-----------------|--------------|-------------|
| Shut down inside Windows | **Yes** (Stopped) | kept | kept |
| Portal Stop / `az vm deallocate` / `Stop-AzVM` | No | **wiped** | may change |

Static private IP (10.10.2.10) and Standard static public IPs survive deallocation.

## Steps (summary)
1. `az vm list-vm-resize-options` / `Get-AzVMSize` to see valid sizes
2. Resize (VM reboots) and verify RAM in Windows
3. In-guest shutdown → "VM stopped"; deallocate → "VM deallocated"
4. Auto-shutdown on both VMs
5. Resize back to B2s; review cost

Scripts: [build-azcli.ps1](scripts/build-azcli.ps1) · [build-azps.ps1](scripts/build-azps.ps1)

## Proof it works
| Test | Before | After |
|------|--------|-------|
| RAM in Windows | ~4 GB (B2s) | ~8 GB (B2ms) |
| `D:\temp-test.txt` after deallocate | present | gone |
| Private IP after deallocate | 10.10.2.10 | 10.10.2.10 |
| Auto-shutdown | none | 23:00 Eastern on 2 VMs |

Screenshots: `screenshots/01-size-b2ms.png`, `screenshots/02-auto-shutdown.png`

## Teardown
[teardown-azcli.ps1](scripts/teardown-azcli.ps1) · [teardown-azps.ps1](scripts/teardown-azps.ps1). Confirm B2s and deallocate. Auto-shutdown is kept on purpose.

## Lessons learned / gotchas
- *(Your words, e.g. `az vm stop` still bills, `az vm auto-shutdown --time` is UTC, cost data lags ~8–24 h.)*

## Cost
~$0.15–0.30 for the lab. Auto-shutdown itself is free.
