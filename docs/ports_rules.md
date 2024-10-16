# Port Rules for Network Connections

This document outlines the port rules for various network connections in our system.

## Main Network Ports

| Protocol | Port  | Description                         |
| -------- | ----- | ----------------------------------- |
| P2P      | 30333 | Peer-to-peer network communications |
| WS       | 30334 | WebSocket connections               |
| WS       | 30335 | Alternative WebSocket port          |
| WSS      | 443   | WebSocket Secure connections        |

## Relaychain and Parachain Ports

| Network Type | Port | Description                            |
| ------------ | ---- | -------------------------------------- |
| Relaychain   | 9300 | RPC port for Relaychain communications |
| Parachain    | 9400 | RPC port for Parachain communications  |

## Monitoring Ports

| Network Type | Port | Description                    |
| ------------ | ---- | ------------------------------ |
| Relaychain   | 7300 | Monitoring port for Relaychain |
| Parachain    | 7400 | Monitoring port for Parachain  |
