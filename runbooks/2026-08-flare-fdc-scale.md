# Flare + FDC scale-out — deploy runbook (2026-08)

Config staged in this branch. Nothing here is live until someone with the
Ansible vault/keys runs the playbooks. Ordered, with safety gates.

## Ground truth (verified against running hosts, NOT the repo)

Flare validators actually running:
- val-flare-01  bkk08  10.8.0.201  pub .201   (MEV binary)
- val-flare-02  bkk07  10.7.0.207  pub .207   (MEV binary)
- val-flare-03  bkk07  10.7.0.204  pub .210   (MEV binary)  ← imported from drift this branch
- val-flare-04  bkk08  10.8.0.210  pub .209   (MEV binary)  ← imported from drift this branch

All four run `avalanchego-mev3` (MEV-patched coreth/txpool). The `flare` role
builds VANILLA go-flare. `pinned_service: True` on 01–04 protects them.

## ⚠️ Non-negotiable safety gate

NEVER run the flare playbook against the whole `[flare]` group. It would rebuild
01–04 vanilla and clobber the MEV binary. Always `--limit` to the new nodes only.

## 1. New validators (05–08) — bring to 4-per-host

Staged host_vars (IPs verified free against live scan):
- val-flare-05 bkk07 10.7.0.205 .212 ::22
- val-flare-06 bkk07 10.7.0.206 .213 ::23
- val-flare-07 bkk08 10.8.0.209 .214 ::24
- val-flare-08 bkk08 10.8.0.212 .215 ::25

Deploy (containers first, then flare install), scoped:
```
ansible-playbook proxmox_setup_vms.yaml --limit 'val-flare-05:val-flare-06:val-flare-07:val-flare-08'
ansible-playbook flare.yaml            --limit 'val-flare-05:val-flare-06:val-flare-07:val-flare-08'
```
These come up VANILLA. For MEV parity, install the MEV binary afterwards
(see §4). Each needs its own P-Chain self-bond tx to register as a validator
(fresh staking keys are generated per node — never clone them).

## 2. Tuomas SSH access (FDC + flare nodes)

Staged: tuomas.pub + all_users + users_with_access on groups fdc_verifier,
flare, and host sgb-fdc-01. Verified ABSENT on nodes today.
```
ansible-playbook <user-mgmt-playbook>.yaml --limit 'fdc_verifier:flare:sgb-fdc-01' --tags user_management
```
This now covers val-flare-01–08 (03/04 imported into inventory this branch).

## 3. FDC indexers — already running

btc/eth/doge/xrp/sgb-fdc-01 indexer+verifier docker stacks are Up & healthy.
No action for entity #1. A SECOND entity does NOT need new source nodes/indexers
— it reuses these. It needs its own fsp submission client + entity keys
(fsp-flare-keys.age holds one set; a 2nd entity needs a 2nd registered set on
EntityManager). fsp-client-01/02 already run.

## 4. MEV build reproducibility (URGENT, separate task)

The MEV patch exists only as binaries on the nodes (avalanchego-mev3, evm.mev3);
the source tree is not a git repo. One disk failure loses it. Capture the diff
vs upstream go-flare v1.14.0 into a real fork (rotkonetworks/go-flare), then point
`flare_git_repo` at the fork so builds are reproducible. Until then, new MEV
validators require hand-copying the binary (more drift).

## Known drift / open items (not changed here — need human decision)

- rpc-people-paseo-01: repo pub .144 vs running .188. Unclear which is intended
  (.144 fits the paseo block; .188 is what's live). On bkk06 (being decommissioned).
- Other untracked containers found running on bkk06/07/08: arb-flare-02, arb-bot-01,
  flare-refill-01, flarev-monitoring, fsp-client-01/02, noble-01, osmosis-01,
  penumbra-web2, and misc (boss, nat64, ixpm, quicnet-bkk07, hyperliquid-01,
  demo-shell, val-kusama-02e, xeye). Import as needed.
- bkk06 → new DC (.180/24 + IPv6 /40): migrate chain data via ZFS snapshot+send,
  regenerate node network keys on the copies.
