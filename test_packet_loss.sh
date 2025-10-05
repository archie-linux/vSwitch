#!/bin/bash
set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <src_namespace_number> <dst_namespace_number>"
    exit 1
fi

SRC_NS="ns$1"
DST_NS="ns$2"

# Validate namespace numbers
for ns in "$1" "$2"; do
    if ! [[ "$ns" =~ ^[0-9]+$ ]] || [ "$ns" -lt 1 ] || [ "$ns" -gt 20 ]; then
        echo "Error: Namespace number must be between 1 and 20."
        exit 1
    fi
done

# Extract destination IP dynamically
DST_IP=$(ip netns exec "$DST_NS" ip -4 addr show veth"$2" | awk '/inet / {print $2}' | cut -d/ -f1)

if [ -z "$DST_IP" ]; then
    echo "Error: Could not determine IP address for $DST_NS"
    exit 1
fi

# Apply 50% packet loss on destination namespace's veth
echo "Applying 50% packet loss on $DST_NS's veth..."
echo
ip netns exec "$DST_NS" tc qdisc add dev veth"$2" root netem loss 50%

echo "Testing ping from $SRC_NS to $DST_IP..."
echo
ip netns exec "$SRC_NS" ping -c 10 "$DST_IP"

# Remove traffic shaping rules
echo "Removing traffic shaping from $DST_NS's veth..."
ip netns exec "$DST_NS" tc qdisc del dev veth"$2" root

echo "Traffic shaping complete."
