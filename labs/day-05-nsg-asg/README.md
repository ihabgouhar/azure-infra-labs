# Day 05: NSGs + Application Security Groups (web → app on 443 only)

> Lab build in my own subscription. Built via Azure portal, Azure CLI and Az PowerShell.

## Scenario
A medical billing company's auditor found the web server could reach **any** port on the app server, including RDP. Only HTTPS may pass from web to app, and new web servers must be covered automatically.

## What I built
- ASGs `asg-web`, `asg-app` (like AD groups for server NICs)
- `nsg-app` on `snet-app`:

| Priority | Rule | Action |
|---------:|------|--------|
| 100 | asg-web → asg-app TCP 443 | Allow |
| 200 | 168.63.129.16 → any TCP 3389 (Bastion Developer) | Allow |
| 4000 | VirtualNetwork → any | Deny (beats the hidden AllowVnetInBound 65000) |

- IIS with a self-signed HTTPS binding on vm-app01

## Proof it works
| Test from vm-web01 | Before | After |
|--------------------|--------|-------|
| 10.10.2.10:443 | open | open |
| 10.10.2.10:3389 | open (audit finding) | **blocked** |

Network Watcher **IP flow verify**: 443 = Allow (rule 100), 3389 = Deny (rule 4000).

Scripts: [build-azcli.ps1](scripts/build-azcli.ps1)

## Lessons learned
- *(Write 2–4 bullets in your own words. This is the part clients read most.)*
