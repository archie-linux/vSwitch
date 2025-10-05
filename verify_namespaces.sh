#!/bin/bash

echo "========== List of Namespaces =========="
echo
ip netns
echo

for i in {1..20}; do
    echo "========== NS$i Interfaces =========="
    echo
    ip netns exec ns$i ip a
    echo
done
