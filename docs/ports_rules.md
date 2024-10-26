# Port Rules for Network Connections

This document outlines the port rules for various network connections in our system.

## P2P Network Ports

| Protocol | Port  | Description                         |
| -------- | ----- | ----------------------------------- |
| P2Prelay      | DIRECT | controlled in fw direct to ports 31000-39999 |
| WSrelay       | 30334 | Relay WebSocket connections               |
| WSSrelay      | 30335 | Relay Alternative WebSocket port          |
| P2Ppara      | DIRECT | controlled in fw direct to ports  31000-39999          |
| WSpara       | 30434 | Parachain WebSocket connections      |
| WSSpara      | 30435 | Parachain secure WebSocket port      |


## P2P custom port naming practice

| Relaychain | Port  | Description                         |
| -------- | ----- | ----------------------------------- |
| Polkadot      | 31xxx | polkadot relay and system parachains |
| PolkadotCustom      | 35xxx | polkadot non-system parachains |
| Kusama       | 32xxx |   |
| KusamaCustom       | 36xxx |   |
| Westend     |  33xxx|           |
| Paseo      |  34xxx|           |
| PaseoCustom      |  38xxx|           |

| Parachain | Port  | Description                         |
| -------- | ----- | ----------------------------------- |
| Relaychain      | 3x0xx | |
| Asset-Hub      | 3x1xx | polkadot/kusama/westend/paseo system-parachain |
| Bridge-Hub       | 3x2xx |   |
| Collectives     |  3x3xx|           |
| People      |  3x4xx|           |
| Coretime      |  3x5xx|           |
| Moonbeam      |  350xx| polkadot custom parachain      |
| Hyperbridge      |  351xx|           |
| Interlay      |  352xx|           |
| Acala     |  353xx|           |
| KILT     |  354xx|           |
| Karura(ksm)     |  363xx|   kusama custom parachain(acala canary)         |
| Kintsugi(ksm)     |  362xx| kusama custom parachain(interlay canary)          |
| Gargantua(paseo)     |  381xx| paseo custom parachain(hyperbridge testnet)          |

## Relaychain and Parachain RPC Ports

| Network Type | Port | Description                            |
| ------------ | ---- | -------------------------------------- |
| Relaychain   | 9300 | RPC port for Relaychain communications |
| Parachain    | 9400 | RPC port for Parachain communications  |
| WSS          | 443  | RPC WebSocket Secure connections       |

## Monitoring Ports

| Network Type | Port | Description                    |
| ------------ | ---- | ------------------------------ |
| Relaychain   | 7300 | Monitoring port for Relaychain |
| Parachain    | 7400 | Monitoring port for Parachain  |
