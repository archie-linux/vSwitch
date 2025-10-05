# Virtual Switch with Namespaces

## Table of Contents
- [Overview](#overview)
- [Setup](#setup)
- [Usage](#usage)
  - [Create Namespaces and Bridge](#create-namespaces-and-bridge)
  - [Test Connectivity](#test-connectivity)
  - [Test Packet Loss](#test-packet-loss)
  - [Test SSH and HTTP](#test-ssh-and-http)
  - [Configure DHCP](#configure-dhcp)
  - [Cleanup](#cleanup)
- [Troubleshooting](#troubleshooting)
- [Potential Future Work](#potential-future-work)

## Overview

This project creates **20 network namespaces** (`ns1` to `ns20`), each representing a virtual host. These namespaces are connected to a **virtual switch** (Linux bridge `br0`) through **veth pairs** (`veth1` to `veth20`), enabling **Layer 2 communication**.

A **DHCP server** runs in one of the namespaces, dynamically assigning IP addresses to the other namespaces. Additionally, **HTTP and SSH services** can be started in any namespace for connectivity testing. The setup simulates a real world network switch for testing and experimentation.

## Key Components:
- **Namespaces:** `ns1` to `ns20` — Isolated network environments acting as virtual hosts.
- **Virtual Switch:** `br0` — A Linux bridge that connects all namespaces.
- **Veth Pairs:** `veth1` to `veth20` — Virtual Ethernet interfaces connecting namespaces to the bridge.
- **DHCP Server:** Provides dynamic IP assignment to the namespaces.
- **Services:** HTTP and SSH services can be run inside namespaces for communication testing.

This setup enables testing of **network connectivity**, **traffic shaping**, and **service reachability** across the namespaces.

## Setup
1. Clone the repository:
```bash
git clone https://github.com/anpa6841/vSwitch.git
cd vSwitch
```

2. Build the Docker image:
```bash
docker build -t vswitch .
```

3. Run the container:
```bash
docker run -it --name vswitch --privileged --network none -v $(pwd):/scripts vswitch /bin/bash -c ./setup_vswitch.sh
```

4. To interact with the running container from another terminal:
```bash
docker exec -it vswitch /bin/bash
```

## Usage

### Create Namespaces and Bridge
Run the script to create namespaces, veth pairs, and bridge:
```bash
./bridge_and_namespace_creation.sh
./configure_dhcp.sh
./assign_dhcp.sh
./verify_namespaces.sh
```


### Test Connectivity
Verify connectivity between namespaces:
```bash
./test_connectivity.sh [src_ns] [tgt_ns]
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
./test_packet_loss.sh <src_namespace_number> <dst_namespace_number>
```

<pre>
root@ae9e87a95490:/scripts# ./test_packet_loss.sh 3 8
Applying 50% packet loss on ns8's veth...

Testing ping from ns3 to 192.168.1.106...

PING 192.168.1.106 (192.168.1.106) 56(84) bytes of data.
64 bytes from 192.168.1.106: icmp_seq=2 ttl=64 time=0.400 ms
64 bytes from 192.168.1.106: icmp_seq=3 ttl=64 time=0.275 ms
64 bytes from 192.168.1.106: icmp_seq=5 ttl=64 time=0.134 ms
64 bytes from 192.168.1.106: icmp_seq=7 ttl=64 time=0.192 ms
64 bytes from 192.168.1.106: icmp_seq=10 ttl=64 time=0.253 ms

--- 192.168.1.106 ping statistics ---
10 packets transmitted, 5 received, 50% packet loss, time 9235ms
rtt min/avg/max/mdev = 0.134/0.250/0.400/0.089 ms
Removing traffic shaping from ns8's veth...
Traffic shaping complete.
</pre>

### Test SSH and HTTP
Test SSH and HTTP communication between namespaces:
```bash
./run_services.sh [ns]
./test_services.sh [src_ns] [dst_ns]
```

<pre>
root@495bd3733a70:/scripts# ./test_services.sh 4 2
Testing HTTP from ns4 to 192.168.1.1...
</pre>

### Configure DHCP
Start the DHCP server and test dynamic IP assignment:
```bash
./configure_dhcp.sh
./sniff_dhcp.sh
./assign_dhcp.sh
```

<pre>
root@64a5d9f93f94:/scripts# ./assign_dhcp.sh
Requesting IP for ns1...
Requesting IP for ns3...
Requesting IP for ns4...
Requesting IP for ns5...
Requesting IP for ns6...
Requesting IP for ns7...
...
...
</pre>

<pre>
root@64a5d9f93f94:/scripts# ./sniff_dhcp.sh
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on veth2, link-type EN10MB (Ethernet), snapshot length 262144 bytes
19:45:58.828667 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 56:fe:cf:5f:8f:66, length 300
19:45:59.833325 IP 192.168.1.1.67 > 192.168.1.100.68: BOOTP/DHCP, Reply, length 300
19:45:59.834071 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 56:fe:cf:5f:8f:66, length 300
19:45:59.837511 IP 192.168.1.1.67 > 192.168.1.100.68: BOOTP/DHCP, Reply, length 300
19:45:59.896647 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from aa:54:40:e9:82:6d, length 300
19:46:00.899420 IP 192.168.1.1.67 > 192.168.1.101.68: BOOTP/DHCP, Reply, length 300
19:46:00.899987 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from aa:54:40:e9:82:6d, length 300
19:46:00.902833 IP 192.168.1.1.67 > 192.168.1.101.68: BOOTP/DHCP, Reply, length 300
19:46:00.956350 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 16:9f:08:a2:c5:b9, length 300
19:46:01.961070 IP 192.168.1.1.67 > 192.168.1.102.68: BOOTP/DHCP, Reply, length 300
...
...
...
</pre>

## Cleanup
Tear down the namespaces and bridge:
```bash
./cleanup.sh
docker rm -f vswitch
```

## Troubleshooting
- **Permission denied with SSH:** Ensure the root password is set (`passwd`), and `/run/sshd` exists.
- **DHCP issues:** Verify `/var/lib/dhcp/dhcpd.leases` exists and ensure proper permissions.
- **Traffic shaping not applied:** Confirm `tc` rules are correctly added (`ip netns exec [ns] tc qdisc show`).
- **Container not running:** `docker start vswitch` and `docker exec -it /bin/bash vswitch`.

## Potential Future Work

Explore and build various real-world network configurations and topologies using Linux namespaces and bridges. These setups are perfect for learning networking concepts, simulating complex environments, and testing configurations.

1. **Basic Router Setup (Namespace as Router)**  
   Purpose: Understand packet forwarding, routing tables, and IP forwarding.  
   - Create three namespaces: `ns1`, `ns2`, `router`.
   - Connect `ns1` and `ns2` to `router` via `veth` pairs.
   - Enable IP forwarding in the `router` namespace.
   - Add routes in `ns1` and `ns2` to send traffic through the router.

2. **NAT (Network Address Translation) Setup**  
   Purpose: Simulate a private network behind a NAT gateway.  
   - Create a private namespace connected to a `nat` namespace.
   - Connect the `nat` namespace to the host’s network.
   - Enable IP forwarding in the `nat` namespace.
   - Set up `iptables` for masquerading to allow private IP access to the external network.

3. **Load Balancer Simulation**  
   Purpose: Test load balancing and understand packet distribution.  
   - Create `lb` (load balancer) namespace and two backend namespaces `ns1`, `ns2`.
   - Use a bridge to connect all namespaces.
   - Run simple web servers in `ns1` and `ns2`.
   - Use `ip route` with multiple next-hops or set up `iptables` for traffic distribution.

4. **Firewall and Intrusion Detection Simulation**  
   Purpose: Experiment with firewall rules and monitor traffic.  
   - Create namespaces for `client`, `firewall`, and `server`.
   - Route traffic through the `firewall` namespace.
   - Set up `iptables` rules in the `firewall` namespace to allow/block traffic.

5. **VRF (Virtual Routing and Forwarding) Simulation**  
   Purpose: Understand VRFs and isolate routing domains.  
   - Create two namespaces `vrf1`, `vrf2`.
   - Connect both to a `router` namespace with separate routing tables per VRF.

6. **VXLAN (Virtual Extensible LAN) Setup**  
   Purpose: Simulate overlay networks across namespaces.  
   - Create two or more namespaces to act as hosts.  
   - Use `ip link add vxlan0` to create VXLAN interfaces in each namespace.  
   - Assign VXLAN IDs (VNIs) to separate overlay networks.  
   - Connect namespaces using `veth` pairs or bridges and route VXLAN traffic between them.  

---

**Note**: The configurations listed above provide a solid foundation for exploring advanced networking concepts. They cover a range of scenarios involving **Layer 3 setups** such as routing, NAT, firewalls, and virtualized network functions. These ideas can be further expanded to simulate **Layer 3 switches**, **dynamic routing protocols**, or even **large-scale enterprise networks**. The combination of Linux namespaces, bridges, and IP routing offers endless possibilities for experimentation and learning.

> “Anything you can imagine can happen inside a namespace.”
