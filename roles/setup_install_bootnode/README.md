# setup_install_bootnode

Chain-agnostic role that renders the bootnode systemd unit and manages the
service. **Binary installation lives in the chain-specific role**
(`setup_install_polkadot`, `setup_install_hydration`, …) — that role still
downloads and symlinks the binary; this one just owns the systemd side.

## Why a separate role

Per-chain `bootnode.service.j2` templates duplicated the v4/v6 listen-addr
block and the surrounding scaffolding. Consolidating gives one place to
edit when adding new transports, new --public-addr forms, or new bind
flags.

## Used by

A bootnode playbook should run the chain role first (to install the
binary) and this role second (to render the unit and start the service):

```yaml
- hosts: bootnodes_polkadot
  roles:
    - setup_install_polkadot   # binary, user, dirs, chain spec
    - setup_install_bootnode   # systemd unit + start
```

Set `default_node_type: bootnode` on the host (host_vars/<host>.yaml) so
the chain role does not also render its own bootnode.service.j2.

## Required variables (set per host or in group_vars)

| Variable | Example | Purpose |
|---|---|---|
| `default_service` | `polkadot`, `hydration` | Binary name + systemd unit name |
| `default_user` / `default_group` | `polkadot` | systemd User=/Group= |
| `default_base_path` | `/opt/polkadot` | Binary + chain dirs |
| `default_network` | `polkadot`, `hydration-paseo` | `--chain` arg |
| `default_telemetry_name` | `Rotko - polkadot-boot-01` | `--name` arg |
| `default_domain` | `polkadot.boot.rotko.net` | `/dns/.../tcp/PORT/wss` multiaddr |
| `default_p2p_port` / `default_p2p_port_ws` / `default_p2p_port_wss` | `31001 / 30334 / 30335` | libp2p TCP / WS / WSS ports |
| `default_rpc_port` | `9300` | `--rpc-port` |
| `default_prom_port` | `7300` | `--prometheus-port` |
| `ansible_host` | `160.22.181.110` | Public IPv4 (used in `--public-addr /ip4/...`) |

## Optional variables

| Variable | Default | Purpose |
|---|---|---|
| `default_node_type` | `bootnode` | Set to `endpoint` etc. to skip unit rendering |
| `default_database` | `paritydb` | `--database` |
| `default_state_pruning` | `256` | `--state-pruning` |
| `default_blocks_pruning` | (unset) | If defined, emits `--blocks-pruning N` |
| `default_syncmode` | `fast-unsafe` | `--sync` |
| `default_log_filters` | `sync=warn,afg=warn,babe=warn` | `--log` |
| `default_relay_rpc` | (unset) | If defined, emits `--relay-chain-rpc-urls ... [fallback]` |
| `default_relay_rpc_fallback` | (unset) | Appended to relay-chain-rpc-urls if defined |
| `default_bootnode_extra_flags` | `[]` | List of extra CLI flags appended verbatim, e.g. `["--no-beefy", "--wasm-execution=Compiled"]` |

## IPv6

Both IPv4 (`/ip4/0.0.0.0/...`) and IPv6 (`/ip6/::/...`) listen-addr lines
are emitted unconditionally via the `listen_addrs` macro in
`templates/_listen_macros.j2`. AAAA records on `default_domain` announce v6
through the standard `/dns/...` multiaddr.

## Migration

`setup_install_polkadot/templates/bootnode.service.j2` and
`setup_install_hydration/templates/bootnode.service.j2` remain in place for
backwards compatibility with existing playbooks. Migrate one chain at a
time by switching its bootnode playbook to run this role after the
chain-install role, then remove the per-chain bootnode template.
