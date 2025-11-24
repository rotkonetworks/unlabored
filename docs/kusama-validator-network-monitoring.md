# Kusama Validator Network Monitoring

## Key Prometheus Metrics for PoV/Chunk Fetch Failures

### 1. Chunk Recovery Success Rate
```promql
# Success rate (should be >95%)
rate(polkadot_parachain_availability_recovery_chunk_requests_finished{type="success"}[5m])
/
rate(polkadot_parachain_availability_recovery_chunk_requests_issued[5m])
* 100
```

### 2. Chunk Recovery Errors by Type
```promql
# Error rate
rate(polkadot_parachain_availability_recovery_chunk_requests_finished{type="error"}[5m])

# Timeout rate
rate(polkadot_parachain_availability_recovery_chunk_requests_finished{type="timeout"}[5m])
```

### 3. Connection Churn (CRITICAL METRIC)
```promql
# Incoming connections per minute
rate(substrate_sub_libp2p_connections_opened_total{direction="in"}[1m]) * 60

# Outgoing connections per minute
rate(substrate_sub_libp2p_connections_opened_total{direction="out"}[1m]) * 60

# Closed connections per minute
rate(substrate_sub_libp2p_connections_closed_total[1m]) * 60
```

### 4. Failed Connection Attempts (System Level)
Monitor via node_exporter:
```promql
# This requires node_exporter with netstat metrics
rate(node_netstat_Tcp_AttemptFails[5m])
```

### 5. Full Data Recovery Errors
```promql
# PoV fetch failures
rate(polkadot_parachain_availability_recovery_full_data_requests_finished{result="error"}[5m])
```

## Current Status (as of monitoring)

### Chunk Recovery Stats:
- **Total Requests**: 755,525
- **Success**: 688,795 (91.2%)
- **Timeout**: 44,291 (5.9%)
- **Error**: 14,373 (1.9%)
- **Failure Rate**: ~8.8%

### Connection Stats:
- **Total Incoming Opened**: 5,566,392
- **Total Outgoing Opened**: 2,507,374
- **Total Closed**: ~7,845,894
- **Active Connections**: ~1,200
- **Connection Churn**: EXTREMELY HIGH - This is the main issue!

### Network Issues:
- 60.4M failed TCP connection attempts
- Massive connection churn indicates:
  - Possible ISP/ASN rate limiting
  - NAT connection tracking issues
  - Firewall state table exhaustion
  - BGP routing instability

## Grafana Dashboard Queries

### Panel 1: PoV Fetch Success Rate
```promql
100 - (
  (
    rate(polkadot_parachain_availability_recovery_chunk_requests_finished{type="error"}[5m]) +
    rate(polkadot_parachain_availability_recovery_chunk_requests_finished{type="timeout"}[5m])
  )
  /
  rate(polkadot_parachain_availability_recovery_chunk_requests_issued[5m])
  * 100
)
```

### Panel 2: Connection Churn Rate
```promql
# Connections opened per second
rate(substrate_sub_libp2p_connections_opened_total[1m])

# Connections closed per second
rate(substrate_sub_libp2p_connections_closed_total[1m])
```

### Panel 3: Network Error Types
```promql
# Group by error type
sum by (type) (
  rate(polkadot_parachain_availability_recovery_chunk_requests_finished{type=~"error|timeout|no_such_chunk"}[5m])
)
```

## Recommendations

### 1. Immediate Actions
- Check ISP/ASN rate limiting policies
- Review BGP route flapping
- Investigate firewall connection limits
- Check NAT state table size on routing infrastructure

### 2. litep2p Configuration
Since litep2p is required by W3F, we need to optimize for it:
- Current flags: `--in-peers 64 --out-peers 64`
- Consider adjusting peer limits if connection churn continues
- Monitor `substrate_sub_libp2p_peers_count` to ensure stable peer set

### 3. Network Optimization
- Increase TCP connection tracking limits at ISP/router level
- Implement connection rate limiting at edge (not dropping)
- Review BGP policies for peer announcement stability
- Check for DDoS mitigation that might be too aggressive

### 4. Monitoring Alerts
Set up alerts for:
- Chunk success rate < 90%
- Connection churn > 100/min
- Failed TCP attempts rate increase > 20%
- Peer count drops below 60

## Investigation Commands

### Check real-time connection churn:
```bash
ssh val-kusama-03 'watch -n 1 "ss -s | grep TCP"'
```

### Monitor connection states:
```bash
ssh val-kusama-03 'netstat -an | grep 32006 | awk "{print \$6}" | sort | uniq -c'
```

### Track bandwidth:
```bash
ssh val-kusama-03 'vnstat -i eth0 --live'
```
