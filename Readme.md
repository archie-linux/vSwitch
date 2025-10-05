# Network Simulator: Virtual Switch with Namespaces

This project creates two network namespaces (`ns1` and `ns2`), each representing a virtual host. These namespaces are connected to a virtual switch (Linux bridge) through veth pairs (`veth1` and `veth2`), enabling Layer 2 communication.

## Table of Contents
- [Setup](#setup)
- [Usage](#usage)
  - [Create Namespaces and Bridge](#create-namespaces-and-bridge)
  - [Test Connectivity](#test-connectivity)
  - [Test Packet Loss](#test-packet-loss)
  - [Test SSH and HTTP](#test-ssh-and-http)
  - [Configure DHCP](#configure-dhcp)
- [Docker Setup](#docker-setup)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

## Setup
1. Clone the repository:
```bash
git clone https://github.com/anpa6841/network-simulator.git
cd network-simulator
```

2. Build the Docker image:
```bash
docker build -t net-sim .
```

3. Run the container:
```bash
docker run -it --name net-sim --privileged --network none -v $(pwd):/scripts net-sim /bin/bash
```

## Usage

### Create Namespaces and Bridge
Run the script to create namespaces, veth pairs, and bridge:
```bash
./bridge_and_namespace_creation.sh
./verify_namespaces.sh
```

### Test Connectivity
Verify connectivity between namespaces:
```bash
./test_connectivity.sh
```

### Sniff ARP Packets
Capture ARP traffic:
```bash
./sniff_arp.sh
```

<pre>
root@60e18620f04a:/scripts# ./sniff_arp.sh 
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on veth2, link-type EN10MB (Ethernet), snapshot length 262144 bytes
16:29:31.652103 ARP, Request who-has 192.168.1.1 tell 192.168.1.2, length 28
16:29:31.652172 ARP, Reply 192.168.1.1 is-at 4e:c8:c9:45:5e:e3 (oui Unknown), length 28
16:29:37.114246 ARP, Request who-has 192.168.1.2 tell 192.168.1.1, length 28
16:29:37.114379 ARP, Reply 192.168.1.2 is-at 52:58:2b:1f:d9:83 (oui Unknown), length 28
</pre>

### Test Packet Loss
Simulate packet loss and delay:
```bash
./test_packet_loss.sh
```

<pre>
root@05732de73b91:/scripts# ./test_packet_loss.sh 
Applied 50% packet loss on ns2. Testing ping...
PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=0.112 ms
64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=0.328 ms
64 bytes from 192.168.1.1: icmp_seq=5 ttl=64 time=0.096 ms
64 bytes from 192.168.1.1: icmp_seq=7 ttl=64 time=0.223 ms
64 bytes from 192.168.1.1: icmp_seq=9 ttl=64 time=0.225 ms

--- 192.168.1.1 ping statistics ---
10 packets transmitted, 5 received, 50% packet loss, time 9201ms
rtt min/avg/max/mdev = 0.096/0.196/0.328/0.084 ms
</pre>

### Test SSH and HTTP
Test SSH and HTTP communication between namespaces:
```bash
./run_services.sh
./test_services.sh
```

### Configure DHCP
Start the DHCP server and test dynamic IP assignment:
```bash
./configure_dhcp.sh
./sniff_dhcp.sh
./test_dhcp.sh
```

<pre>
root@96f3bc1372a8:/scripts# ./test_dhcp.sh 
6: veth1@if5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 96:88:b6:7e:82:d5 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.1.2/24 scope global veth1
       valid_lft forever preferred_lft forever
    inet 192.168.1.100/24 brd 192.168.1.255 scope global secondary dynamic veth1
       valid_lft 43200sec preferred_lft 43200sec
    inet6 fe80::9488:b6ff:fe7e:82d5/64 scope link 
       valid_lft forever preferred_lft forever
</pre>

<pre>
root@96f3bc1372a8:/scripts# ./sniff_dhcp.sh 
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on veth2, link-type EN10MB (Ethernet), snapshot length 262144 bytes
17:06:44.744659 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 96:88:b6:7e:82:d5, length 300
17:06:45.747413 IP 192.168.1.1.67 > 192.168.1.100.68: BOOTP/DHCP, Reply, length 300
17:06:45.747988 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 96:88:b6:7e:82:d5, length 300
17:06:45.752433 IP 192.168.1.1.67 > 192.168.1.100.68: BOOTP/DHCP, Reply, length 300
</pre>

### Release DHCP Lease
Force lease renewal
```
ip netns exec ns1 dhclient -v -r veth1
./verify_namespaces.sh # removes previously assigned static ip as well
./test_dhcp.sh
```

## Docker Setup

To interact with the running container from another terminal:
```bash
docker exec -it net-sim /bin/bash
```

## Troubleshooting
- **Permission denied with SSH:** Ensure the root password is set (`passwd`), and `/run/sshd` exists.
- **DHCP issues:** Verify `/var/lib/dhcp/dhcpd.leases` exists and ensure proper permissions.
- **Traffic shaping not applied:** Confirm `tc` rules are correctly added (`tc qdisc show`).

## Cleanup
Tear down the namespaces and bridge:
```bash
./cleanup.sh
docker rm -f net-sim
```
