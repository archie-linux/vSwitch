set -e

# Start HTTP server in ns2
ip netns exec ns2 python3 -m http.server 80 &

# Set root passwd
ip netns exec ns2 sh -c "echo 'root:password' | chpasswd"

# Start SSH server in ns2
ip netns exec ns2 sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
ip netns exec ns2 sed -i 's/^#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
ip netns exec ns2 mkdir -p /run/sshd
ip netns exec ns2 /etc/init.d/ssh start

