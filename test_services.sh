#!/bin/bash
set -e

# Test HTTP from ns1
ip netns exec ns1 curl http://192.168.1.1

# Test SSH from ns1 (assuming a user "root" or create one if needed)
ip netns exec ns1 ssh root@192.168.1.1
