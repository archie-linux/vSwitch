#!/bin/bash
set -e

# Assign DHCP for each namespace
for i in $(seq 1 20); do
    ns="ns$i"
    veth="veth$i"

    if [ "$ns" != "ns2" ]; then
        echo "Requesting IP for $ns..."
        ip netns exec "$ns" dhclient veth"${ns#ns}"
    fi
done

echo "DHCP IPs assigned to all namespaces!"
