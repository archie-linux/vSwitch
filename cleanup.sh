#!/bin/bash
set -e

# Delete namespaces ns1 to ns20
for i in {1..20}; do
    ip netns del "ns$i" 2>/dev/null || true
done

# Delete the bridge interface
ip link del br0 2>/dev/null || true

# Delete veth pairs
for i in {1..20}; do
    ip link del "veth${i}-br" 2>/dev/null || true
done

echo "Cleanup complete."
