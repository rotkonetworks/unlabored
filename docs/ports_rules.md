# Network Port Rules

This document outlines the port rules for various network connections in the system.

**UP TO DATE rules:**
**https://github.com/rotkonetworks/portgen**

## P2P Network Ports

| Protocol | Port | Description |
| --- | --- | --- |
| P2Prelay | DIRECT | Controlled in firewall, direct to ports 31000-39999 |
| WSrelay | 30334 | Relay WebSocket connections |
| WSSrelay | 30335 | Relay alternative WebSocket port |
| P2Ppara | DIRECT | Controlled in firewall, direct to ports 31000-39999 |
| WSpara | 30434 | Parachain WebSocket connections |
| WSSpara | 30435 | Parachain secure WebSocket port |

## P2P Custom Port Naming Practice

| Relaychain | Port | Description |
| --- | --- | --- |
| Polkadot | 31xxx | Polkadot relay and system parachains |
| PolkadotCustom | 35xxx | Polkadot non-system parachains |
| Kusama | 32xxx | - |
| KusamaCustom | 36xxx | - |
| Westend | 33xxx | - |
| Paseo | 34xxx | - |
| PaseoCustom | 38xxx | - |

| Parachain | Port | Description |
| --- | --- | --- |
| Relaychain | 3x0xx | - |
| Asset-Hub | 3x1xx | Polkadot/Kusama/Westend/Paseo system-parachain |
| Bridge-Hub | 3x2xx | - |
| Collectives | 3x3xx | - |
| People | 3x4xx | - |
| Coretime | 3x5xx | - |
| Moonbeam | 350xx | Polkadot custom parachain |
| Hyperbridge | 351xx | - |
| Interlay | 352xx | - |
| Acala | 353xx | - |
| KILT | 354xx | - |
| Karura (KSM) | 363xx | Kusama custom parachain (Acala canary) |
| Kintsugi (KSM) | 362xx | Kusama custom parachain (Interlay canary) |
| Gargantua (Paseo) | 381xx | Paseo custom parachain (Hyperbridge testnet) |

| Roles | Port |
| --- | --- |
| Bootnode | 3xx1x |
| Validator/Collator | 3xx2x |
| RPC | 3xx3x |

| Order Number | Port |
| --- | --- |
| rpc-polkadot-01 | 3xxx1 |
| rpc-polkadot-02 | 3xxx2 |
| rpc-polkadot-08 | 3xxx8 |

Example:
Paseo People chain bootnode p2p port: 34411

## Relaychain and Parachain RPC Ports

| Network Type | Port | Description |
| --- | --- | --- |
| Relaychain | 9300 | RPC port for Relaychain communications |
| Parachain | 9400 | RPC port for Parachain communications |
| WSS | 443 | RPC WebSocket Secure connections |

## Monitoring Ports

| Network Type | Port | Description |
| --- | --- | --- |
| Relaychain | 7300 | Monitoring port for Relaychain |
| Parachain | 7400 | Monitoring port for Parachain |
