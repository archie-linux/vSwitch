#!/bin/bash

# Show help message if arguments are missing
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <src_ns> <tgt_ns>"
  exit 1
fi

src_ns=$1
tgt_ns=$2

# Get target namespace IP address
tgt_ip=$(ip netns exec ns$tgt_ns ip -4 addr show veth$tgt_ns | awk '/inet / {print $2}' | cut -d'/' -f1)

# Ping from src_ns to tgt_ip
ip netns exec ns$src_ns ping -c 3 "$tgt_ip"
