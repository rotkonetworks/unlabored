## Naming Conventions

The Rotko Networks' infrastructure encompasses various types of machines, each
with distinct roles. Each machine has a unique identifier assigned to it,
derived from its function and sequence within the system. The naming structure
leverages prefixes to signify the type of machine:

- **`bkk`**: Denotes Proxmox hosts and routers.
- **`dot`**: Represents Polkadot nodes.
- **`ksm`**: Designates Kusama nodes.

The number succeeding the prefix pinpoints the sequence or role of the machine
within its category. For instance, `dot01` corresponds to the first Polkadot
node in the system.

## Proxmox IDs, Ports, and IP Addresses

Our Proxmox ID, port numbering, and IP address assignments are designed to
follow a consistent and logical structure. For instance, consider the `vmid`
for `dot01` which is `111`, and for `dot02`, it's `112`. 

In this pattern:
- The first digit signifies the network type (`1` for `dot`, `2` for `ksm`).
- The second digit represents the host sequence number within that network.
- The third digit designates the machine sequence number at the host.

This pattern provides an easy-to-follow logic that helps identify the machine's
role, its host, and its sequence within the host.

For example, consider a Kusama node in `bkk03` with a `vmid` of `323` (ksm33).
The leading digit (`3`) indicates that it's a Kusama node, the second digit
(`2`) denotes that it's in the host `bkk02`, and the third digit (`3`)
signifies it's the third machine on that host. The internal IP for this machine
will be `192.168.69.23`.

Similarly, the port used by this machine will be a 5-digit number with the
format `xx323`, where `xx` is unique to the particular service that the port is
used for.

This numbering system provides an easy way to identify the machine's network,
its host, its sequence within the host, and the services running on it, purely
from its `vmid`, IP, and port. This simplifies network management,
troubleshooting, and documentation.
