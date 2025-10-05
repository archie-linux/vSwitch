#!/bin/bash
set -e

# Add packet loss on ns2's veth2
ip netns exec ns2 tc qdisc add dev veth2 root netem loss 50%
echo "Applied 50% packet loss on ns2. Testing ping..."
ip netns exec ns1 ping -c 10 192.168.1.1

# Remove traffic shaping rules
ip netns exec ns2 tc qdisc del dev veth2 root

echo "Traffic Shaping Complete."
