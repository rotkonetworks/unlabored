# Port Rules for Network Connections

This document outlines the port rules for various network connections in our system.

## P2P Network Ports

| Protocol | Port  | Description                         |
| -------- | ----- | ----------------------------------- |
| P2Prelay      | DIRECT | controlled in fw direct to ports 33000-33999 |
| WSrelay       | 30334 | Relay WebSocket connections               |
| WSSrelay      | 30335 | Relay Alternative WebSocket port          |
| P2Ppara      | DIRECT | controlled in fw direct to ports 34000-34999|
| WSpara       | 30434 | Parachain WebSocket connections      |
| WSSpara      | 30435 | Parachain secure WebSocket port      |

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
