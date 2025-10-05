#!/bin/bash
set -e

echo "Testing connectivity..."
ip netns exec ns1 ping -c 4 192.168.1.1

echo "Connectivity test complete."
