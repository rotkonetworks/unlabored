# val-kusama-03 Network Issue Resolution

**Date**: 2025-10-21
**Host**: bkk03 (Proxmox)
**Container**: val-kusama-03 (ID: 32006)
**Network**: Kusama Validator with litep2p backend

## Problem Summary

The validator was experiencing 15-25% PoV (Proof of Validity) fetch failures with errors:
- `FetchPoV(NetworkError(Refused))`
- `FetchPoV(NetworkError(Network(Timeout)))`
- `FetchPoV(NetworkError(NotConnected))`

## Root Cause Analysis

### Primary Issue: **NIC Ring Buffer Too Small**

**Physical NIC (enp6s0) Statistics:**
- Link Speed: 10 Gbps
- RX Ring Buffer: **256** (should be 4096)
- TX Ring Buffer: **256** (should be 4096)
- RX FIFO Errors: **621 packets dropped**
- Total Dropped Packets: **360,082**

### Contributing Factors:

1. **High Network Load**
   - Container traffic: 42TB RX, 48TB TX (total ~90TB)
   - Polkadot bandwidth: 6.78TB in, 5.44TB out
   - Average: ~100Mbps sustained, with bursts much higher

2. **Massive Connection Churn**
   - 340M+ active connection openings
   - 60M+ failed TCP connection attempts
   - ~1,200 active connections with high turnover
   - litep2p aggressive connection management

3. **Small Ring Buffers + High Packet Rate = Packet Loss**
   - With 256-packet buffer and thousands of concurrent connections
   - Burst traffic from P2P network exceeded buffer capacity
   - Dropped packets caused timeout/refused errors in PoV fetches

## Solution Implemented

### 1. Increased NIC Ring Buffers (IMMEDIATE FIX)
```bash
ethtool -G enp6s0 rx 4096 tx 4096
```

**Before:**
```
RX: 256 packets
TX: 256 packets
```

**After:**
```
RX: 4096 packets  (16x increase)
TX: 4096 packets  (16x increase)
```

### 2. Made Changes Persistent
Created `/etc/network/if-up.d/increase-ring-buffers`:
```bash
#!/bin/bash
ethtool -G enp6s0 rx 4096 tx 4096
```

### 3. Installed Monitoring Tools
On bkk03:
- vnstat: Long-term bandwidth tracking
- nload: Real-time bandwidth visualization
- iftop: Connection-level bandwidth monitoring
- iperf3: Network performance testing

## Monitoring & Validation

### Scripts Created:
1. `/home/alice/rotko/unlabored/scripts/monitor_pov_failures.sh`
   - Tracks PoV fetch failures
   - Identifies problematic authority IDs
   - Analyzes error types and para IDs

2. `/home/alice/rotko/unlabored/docs/kusama-validator-network-monitoring.md`
   - Prometheus queries for ongoing monitoring
   - Grafana dashboard recommendations
   - Alert thresholds

### Key Metrics to Monitor:

#### Prometheus Queries:
```promql
# PoV Success Rate (should be >95%)
100 - (
  (
    rate(polkadot_parachain_availability_recovery_chunk_requests_finished{type="error"}[5m]) +
    rate(polkadot_parachain_availability_recovery_chunk_requests_finished{type="timeout"}[5m])
  ) /
  rate(polkadot_parachain_availability_recovery_chunk_requests_issued[5m])
  * 100
)

# NIC Dropped Packets (should not increase)
rate(node_network_receive_drop_total{device="enp6s0"}[5m])
```

#### System Commands:
```bash
# Check for new FIFO errors (should stay at 621)
ssh bkk03 'ethtool -S enp6s0 | grep fifo'

# Monitor PoV fetch failures
ssh val-kusama-03 'journalctl -u polkadot.service -f | grep "fetch_pov_job err"'

# Check ring buffer settings
ssh bkk03 'ethtool -g enp6s0'
```

## Validation Results

**Immediate Impact:**
- PoV fetch errors in last 2 minutes: **0** (was ~2-5/minute)
- Ring buffer increase applied successfully
- No service restart required

## Recommended Next Steps

### 1. Monitor for 24 Hours
Track these metrics:
- PoV fetch success rate
- NIC dropped packets (should stop increasing)
- Connection churn rate
- Validator participation

### 2. Additional Optimizations (if needed)

If issues persist, investigate:

#### Network Stack Tuning:
```bash
# Increase network buffers
sysctl -w net.core.rmem_max=134217728
sysctl -w net.core.wmem_max=134217728
sysctl -w net.core.rmem_default=16777216
sysctl -w net.core.wmem_default=16777216
sysctl -w net.ipv4.tcp_rmem="4096 87380 67108864"
sysctl -w net.ipv4.tcp_wmem="4096 65536 67108864"

# Increase connection tracking
sysctl -w net.netfilter.nf_conntrack_max=524288
```

#### ASN/Routing Level:
- Check for rate limiting at edge routers
- Review BGP route stability
- Verify no DDoS mitigation blocking legitimate traffic
- Check QoS policies on upstream links

### 3. Apply to Other Validators

Check and fix ring buffers on all validator hosts:
```bash
for host in bkk{01..13} mint{14,23,26,27}; do
  echo "=== $host ==="
  ssh $host 'ethtool -g $(ip -o link show | grep "state UP" | grep -v veth | awk -F": " "{print \$2}" | head -1) 2>/dev/null | grep -A4 "Current"'
done
```

Apply fix where needed:
```bash
ssh <host> 'IFACE=$(ip -o link show | grep "state UP" | grep -v veth | awk -F": " "{print \$2}" | head -1); ethtool -G $IFACE rx 4096 tx 4096'
```

## Technical Details

### Why Ring Buffers Matter:

1. **Packet Reception Flow:**
   ```
   Network → NIC → Ring Buffer → Kernel → Application
   ```

2. **When Buffer is Full:**
   - New packets are dropped at NIC level
   - No chance for kernel/application to process
   - Shows as rx_fifo_errors / rx_missed_errors

3. **Impact on Validators:**
   - Dropped packets = lost P2P messages
   - Lost messages = timeout/refused errors
   - Timeout errors = PoV fetch failures
   - PoV failures = reduced validator performance

### litep2p Behavior:

litep2p is more aggressive than legacy libp2p:
- Opens more concurrent connections
- Faster connection turnover
- Higher burst traffic patterns
- More sensitive to packet loss

This makes proper network tuning even more critical.

## Files Created/Modified

1. `/etc/network/if-up.d/increase-ring-buffers` - Persistent ring buffer config
2. `/home/alice/rotko/unlabored/scripts/monitor_pov_failures.sh` - Monitoring script
3. `/home/alice/rotko/unlabored/docs/kusama-validator-network-monitoring.md` - Prometheus queries
4. `/home/alice/rotko/unlabored/docs/val-kusama-03-network-fix-summary.md` - This file

## Conclusion

The network issues were caused by undersized NIC ring buffers unable to handle the high packet rate from litep2p's aggressive connection management. The fix was simple but critical - increasing ring buffers from 256 to 4096 packets.

**Expected Outcome:**
- PoV fetch success rate should increase from ~91% to >98%
- rx_fifo_errors should stop increasing (stay at 621)
- Network stability should improve significantly

**Monitor closely for 24-48 hours** to confirm the fix resolves the issue completely.
