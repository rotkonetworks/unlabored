#!/bin/bash
# Monitor PoV fetch failures and track problematic peers
# Usage: ./monitor_pov_failures.sh [duration_in_minutes]

DURATION=${1:-10}
HOST=${2:-val-kusama-03}
RPC_PORT=8545

echo "Monitoring PoV fetch failures on $HOST for $DURATION minutes..."
echo "Started at: $(date)"
echo "=========================================="

# Collect failures over the time period
TEMP_LOG="/tmp/pov_failures_$(date +%s).log"

echo "Collecting failure logs..."
ssh $HOST "journalctl -u polkadot.service --since '${DURATION} minutes ago' | grep 'fetch_pov_job err'" > "$TEMP_LOG"

# Extract and count authority IDs
echo ""
echo "Top 20 Authority IDs with most failures:"
echo "=========================================="
grep -oP 'authority_id=Public\(\K[^)]+' "$TEMP_LOG" | \
    sort | uniq -c | sort -rn | head -20 | \
    awk '{printf "%4d failures: %s...\n", $1, substr($2,1,20)}'

# Count error types
echo ""
echo "Error breakdown:"
echo "=========================================="
grep -oP 'err=\K[^)]+\)' "$TEMP_LOG" | sort | uniq -c | sort -rn

# Get current peer connections with IPs
echo ""
echo "Analyzing current peer connections..."
PEERS_FILE="/tmp/peers_$(date +%s).json"
ssh $HOST "curl -s -H 'Content-Type: application/json' -d '{\"id\":1, \"jsonrpc\":\"2.0\", \"method\": \"system_peers\", \"params\": []}' http://localhost:$RPC_PORT" > "$PEERS_FILE"

# Extract connected peer IPs from active connections
echo ""
echo "Top 20 peer IPs by connection count:"
echo "=========================================="
ssh $HOST "ss -tnp | grep polkadot | grep ESTAB | awk '{print \$5}' | cut -d: -f1" | \
    sort | uniq -c | sort -rn | head -20 | \
    awk '{printf "%4d connections: %s\n", $1, $2}'

# Network statistics
echo ""
echo "Network statistics:"
echo "=========================================="
ssh $HOST "cat /proc/net/sockstat | grep TCP"
ssh $HOST "netstat -s | grep -A3 'Tcp:'"

# Count total failures
TOTAL_FAILURES=$(wc -l < "$TEMP_LOG")
echo ""
echo "Summary:"
echo "=========================================="
echo "Total PoV fetch failures in last $DURATION minutes: $TOTAL_FAILURES"
echo "Log file saved to: $TEMP_LOG"
echo "Peers data saved to: $PEERS_FILE"

# Para ID breakdown
echo ""
echo "Failures by Para ID:"
echo "=========================================="
grep -oP 'para_id=Id\(\K[^)]+' "$TEMP_LOG" | \
    sort | uniq -c | sort -rn | \
    awk '{printf "Para %4s: %4d failures\n", $2, $1}'
