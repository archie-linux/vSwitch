#!/bin/bash

echo "========== List Namespaces =========="
echo
ip netns
echo

echo "========== NS1 Interfaces =========="
echo
ip netns exec ns1 ip a
echo

echo "========== NS2 Interfaces =========="
echo
ip netns exec ns2 ip a
echo
