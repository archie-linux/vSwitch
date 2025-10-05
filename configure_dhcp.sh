#!/bin/bash
set -e

# Install DHCP server if not already installed
ip netns exec ns2 mkdir -p /var/lib/dhcp
ip netns exec ns2 touch /var/lib/dhcp/dhcpd.leases

# Configure DHCP server
cat << EOF > /etc/dhcp/dhcpd.conf
subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.100 192.168.1.200;
  option routers 192.168.1.1;
}
EOF

# Start DHCP server in ns2
ip netns exec ns2 dhcpd -cf /etc/dhcp/dhcpd.conf veth2

