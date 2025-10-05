#!/bin/bash
set -e

# Check for namespace argument, default to ns2 if not provided
NS="ns${1:-2}"

# Fetch the veth IP inside the namespace
VETH_IP=$(ip netns exec "$NS" ip -4 -o addr show | awk '/inet/ {split($4, a, "/"); print a[1]}' | grep "192.168")

echo "Namespace: $NS, IP: $VETH_IP"

if ip netns exec "$NS" ss -ltpn | grep -q ":80 "; then
    echo "HTTP server is already running in $NS."
else
    echo "Starting HTTP server in $NS..."
    # Start HTTP server bound to the namespace IP to avoid conflicts
    ip netns exec "$NS" python3 -m http.server 80 --bind "$VETH_IP" &
fi

# Set root password (adjust if needed)
echo "Setting root password in $NS..."
ip netns exec "$NS" sh -c "echo 'root:password' | chpasswd"

# Configure SSH
echo "Configuring SSH server in $NS..."
ip netns exec "$NS" sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
ip netns exec "$NS" sed -i 's/^#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Make sure /run/sshd exists and start the SSH server
echo "Restarting SSH server in $NS..."
ip netns exec "$NS" mkdir -p /run/sshd
ip netns exec "$NS" /etc/init.d/ssh restart || ip netns exec "$NS" /etc/init.d/ssh start

echo "HTTP and SSH servers started in $NS."
