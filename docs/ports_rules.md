# Port Rules for Network Connections

This document outlines the port rules for various network connections in our system.

## P2P Network Ports

| Protocol | Port  | Description                         |
| -------- | ----- | ----------------------------------- |
| P2P      | 30333 | Peer-to-peer network communications |
| WS       | 30334 | WebSocket connections               |
| WSS      | 30335 | Alternative WebSocket port          |
| P2P      | 30433 | Bootnode p2p network communications |
| WS       | 30434 | Bootnode WebSocket connections      |
| WSS      | 30435 | Bootnode secure WebSocket port      |
| WSS      | 443   | if possible for wss                 |

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
