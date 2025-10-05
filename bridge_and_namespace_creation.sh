#!/bin/bash

# Create ns2 first (static IP for service namespace)
ip netns add ns2

# Create bridge
ip link add name br0 type bridge
ip link set br0 up

# Create veth2 (ns2) and attach to bridge
ip link add veth2 type veth peer name veth2-br
ip link set veth2 netns ns2

# Attach veth2-br to bridge and bring it up
ip link set veth2-br master br0
ip link set veth2-br up

# Configure ns2 with static IP 192.168.1.1
ip netns exec ns2 ip addr add 192.168.1.1/24 dev veth2
ip netns exec ns2 ip link set veth2 up

# Enable loopback in ns2
ip netns exec ns2 ip link set lo up

echo "ns2 setup complete with static IP 192.168.1.1"

# Create additional namespaces and veth pairs
for i in {1..20}; do
    ns_name="ns$i"
    
    # Skip ns2 (already created)
    if [ "$ns_name" == "ns2" ]; then
        continue
    fi
    
    echo "Creating namespace: $ns_name"
    ip netns add "$ns_name"

    # Create veth pairs
    veth_name="veth$i"
    veth_br_name="veth$i-br"
    ip link add "$veth_name" type veth peer name "$veth_br_name"

    # Move veth interface to namespace
    ip link set "$veth_name" netns "$ns_name"

    # Attach the other side to the bridge
    ip link set "$veth_br_name" master br0
    ip link set "$veth_br_name" up

    # Bring up veth in namespace
    ip netns exec "$ns_name" ip link set "$veth_name" up

    # Enable loopback in namespace
    ip netns exec "$ns_name" ip link set lo up

    echo "$ns_name setup complete."
done

echo "Network setup complete."
