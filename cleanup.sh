#!/bin/bash
set -e

ip netns del ns1 || true
ip netns del ns2 || true
ip link del br0 || true
ip link delete veth1-br 2>/dev/null
ip link delete veth2-br 2>/dev/null

echo "Cleanup complete."

