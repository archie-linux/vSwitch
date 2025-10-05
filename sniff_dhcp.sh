#!/bin/bash
set -e

# Sniff ARP packets on the bridge
ip netns exec ns2 tcpdump -i veth2 -n port 67 or port 68

