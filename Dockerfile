FROM ubuntu:latest
RUN apt-get update && apt-get install -y iproute2 iputils-ping net-tools tcpdump python3 isc-dhcp-client isc-dhcp-server openssh-server curl
WORKDIR /scripts
CMD ["/bin/bash"]
