# Hetzner Networking
Accept forward/output traffic into your dhcp CIDR block traffic into internal
IP addresses.

## Private networks
  - "0.0.0.0/8"
  - "10.0.0.0/8"
  - "100.64.0.0/10"
  - "127.16.0.0/12"
  - "169.254.0.0/16"
  - "172.16.0.0/12"
  - "192.0.0.0/24"
  - "192.0.2.0/24"
  - "192.88.99.0/24"
  - "192.168.0.0/16"
  - "198.18.0.0/15"
  - "198.51.100.0/24"
  - "203.0.113.0/24"
  - "224.0.0.0/4"
  - "240.0.0.0/4"
  - "255.255.255.255/32"

## Links
https://github.com/ledgerwatch/erigon/issues/6034 most informative topic regarding
disable ipv6: https://github.com/ledgerwatch/erigon/issues/6117
- echo 1 > /sys/module/ipv6/parameters/disable
- https://www.golinuxcloud.com/linux-check-ipv6-enabled/
- https://community.hetzner.com/tutorials/block-outgoing-traffic-to-private-networks
![FORWRD-chain solution](lxc-port-forwarding-rules.png)
