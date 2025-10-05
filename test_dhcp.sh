#!/bin/bash
set -e 

# Request IP in ns1
ip netns exec ns1 dhclient veth1
ip netns exec ns1 ip addr show veth1

