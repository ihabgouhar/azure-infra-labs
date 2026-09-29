# Naming standard

| Resource | Pattern | Example |
|----------|---------|---------|
| Resource group | `rg-<workload>-<env>-<region>` | `rg-lab-core-eus2` |
| Virtual network | `vnet-<name>-<region>` | `vnet-lab-eus2`, `vnet-hub-eus2` |
| Subnet | `snet-<tier>` | `snet-web`, `snet-app`, `snet-mgmt` |
| VM | `vm-<role><nn>` | `vm-app01`, `vm-dc01` |
| NSG | `nsg-<tier>` | `nsg-app` |
| ASG | `asg-<tier>` | `asg-web` |
| Public IP | `pip-<vm>` | `pip-web01` |
| Managed disk | `disk-<vm>-<purpose><nn>` | `disk-app01-data01` |
| Snapshot | `snap-<vm>-<disk>` | `snap-app01-data01` |

Every lab resource carries the tag `day=NN` so a lab's resources can be found and removed as a set.
