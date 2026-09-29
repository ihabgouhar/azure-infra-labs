# Azure Infrastructure Labs: Windows Server, VMs & Networking

Hands-on Azure IaaS labs built by **Ihab Gouhar**, an Infrastructure & Cloud Engineer with 15+ years on Windows Server, Active Directory, GPO, DNS/DHCP, VMware/Proxmox and AVD/FSLogix.

Each lab is written like a client ticket (scenario, build, proof, teardown) and is built **three ways**: Azure portal, Azure CLI, and Az PowerShell, all using the same naming standard.

> These are lab builds in my own Azure subscription, not client environments.

## Lab index

| Day | Lab | Skills shown | Status |
|----:|-----|--------------|--------|
| 01 | [Resource groups, tags, budget alert](labs/day-01-foundations/) | Governance, cost control | ✅ |
| 02 | [VNet + subnets (portal then CLI)](labs/day-02-vnet-subnets/) | VNet design, IP planning | ✅ |
| 03 | [Windows Server 2022 VM + Bastion Developer](labs/day-03-windows-vm-bastion/) | VM build, secure access | ✅ |
| 04 | [Ubuntu VM + cloud-init + NSG](labs/day-04-ubuntu-nginx/) | Linux VM, NSG basics | ✅ |
| 05 | [NSGs + Application Security Groups](labs/day-05-nsg-asg/) | Micro-segmentation, Network Watcher | ✅ |
| 06 | [Managed disks: add, expand, snapshot, restore](labs/day-06-managed-disks/) | Storage, DR basics | ✅ |
| 07 | [VM sizing, deallocate, auto-shutdown, cost](labs/day-07-vm-sizing/) | Right-sizing, FinOps | ✅ |
| 08 | [Custom Script Extension + Run Command](labs/day-08-custom-script-extension/) | Automation without RDP | ✅ |

New labs get added to this table as they are completed.

## Lab environment

| Item | Value |
|------|-------|
| Resource group | `rg-lab-core-eus2` (East US 2) |
| VNet | `vnet-lab-eus2` 10.10.0.0/16 |
| Subnets | `snet-web` 10.10.1.0/24 · `snet-app` 10.10.2.0/24 · `snet-mgmt` 10.10.3.0/24 |
| Access | Azure Bastion (Developer SKU), no RDP/SSH exposed to the internet |
| VMs | `vm-app01` Windows Server 2022 (B2s, static 10.10.2.10) · `vm-web01` Ubuntu 24.04 (B1s) |

See [docs/naming-standard.md](docs/naming-standard.md).

## How each lab folder is organised

```
labs/day-NN-topic/
├── README.md          # scenario, design, steps, proof, lessons learned
├── scripts/           # build + teardown in Azure CLI and Az PowerShell (.ps1)
└── screenshots/       # portal evidence (no subscription IDs / IPs visible)
```

## Contact
Available for small, fixed-scope Azure IaaS work: VM builds, VNet/NSG design, Windows Server/AD in Azure, AVD/FSLogix. Upwork: *add your profile link here*.
