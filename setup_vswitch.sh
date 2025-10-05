#!/bin/bash

./bridge_and_namespace_creation.sh
./configure_dhcp.sh
./assign_dhcp.sh
./verify_namespaces.sh
./test_connectivity.sh 4 10
