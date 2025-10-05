#!/bin/bash
set -e

# Create namespaces
ip netns add ns1
ip netns add ns2

# Create bridge
ip link add br0 type bridge
ip link set br0 up

# Create veth pairs
ip link add veth1 type veth peer name veth1-br
ip link add veth2 type veth peer name veth2-br

# Attach veths to namespaces
ip link set veth1 netns ns1
ip link set veth2 netns ns2

# Attach other ends to the bridge
ip link set veth1-br master br0
ip link set veth2-br master br0
ip link set veth1-br up
ip link set veth2-br up

# Assign IPs
ip netns exec ns1 ip addr add 192.168.1.2/24 dev veth1
ip netns exec ns2 ip addr add 192.168.1.1/24 dev veth2
ip netns exec ns1 ip link set veth1 up
ip netns exec ns2 ip link set veth2 up

echo "Bridge and namespaces setup complete!"
