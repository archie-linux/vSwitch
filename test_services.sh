#!/bin/bash
set -e

# Check for namespace arguments, default to ns1 → ns2 if not provided
SRC_NS="ns${1:-1}"
DST_NS="ns${2:-2}"

# Extract veth IP from the destination namespace
DST_IP=$(ip netns exec "$DST_NS" ip -4 addr show veth"$2" | awk '/inet / {print $2}' | cut -d/ -f1)


if [ -z "$DST_IP" ]; then
  echo "No veth IP found in $DST_NS"
  exit 1
fi

echo "Testing HTTP from $SRC_NS to $DST_IP..."
ip netns exec "$SRC_NS" curl -s "http://$DST_IP" || echo "HTTP request failed."

echo "Testing SSH from $SRC_NS to $DST_IP..."
ip netns exec "$SRC_NS" ssh -o StrictHostKeyChecking=no "root@$DST_IP" || echo "SSH connection failed."

echo "Tests completed."
