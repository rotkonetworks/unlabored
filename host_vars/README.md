## Infrastructure Numbering Logic

### First Digit - Role:

- **1xx**: Validator
- **2xx**: Bootnode
- **3xx**: RPC endpoint
- **4xx**: Parachain Collator
- **5xx**: Parachain Bootnode
- **6xx**: Parachain RPC endpoint

### Second Digit - Network:

For primary networks:
- **x1x**: Polkadot
- **x2x**: Kusama
- **x3x**: Westend

For parachains, the base logic is used, e.g., `wch` would be calculated as `westend(3) * third parachain(3) = 9`.

- **x0x**: Encointer
- **x1x**: Statemint
- **x2x**: Statemine
- **x3x**: Westmint
- **x4x**: Polkadot Bridge Hub
- **x5x**: Kusama Bridge Hub
- **x6x**: Westend Bridge Hub
- **x7x**: Polkadot NFT Hub
- **x8x**: Kusama NFT Hub
- **x9x**: Westend NFT Hub

### Third Digit - Chain or Server:

- **xx4**: Identifier for `bkk04` server.


## Host naming

- **0x**: Validator
- **1x**: Bootnode
- **2x**: RPC endpoint

- **x4**: Identifier for `bkk04` server.
