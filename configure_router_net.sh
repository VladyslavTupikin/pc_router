#!/bin/bash

# Uncomment below for script debugging
# set -x

BRIDGE_NAME="br_rpi"
BRIDGE_MAC="1a:df:e7:82:55:ad"

# IP address should be GW address out of the local DHCP server range.
# local DHCP server is dnsmasq. IP range set from 192.168.10.10 to 192.168.10.50
BRIDGE_LAN_IP="192.168.10.1"
BRIDGE_LAN_MASK="24"

# In current config WAN interface is WiFi interface
IFACE_WIFI="wlp3s0"

# In current config LAN interface is physical interface
IFACE_ETH="enx3c18a0161be8"

# Set sshd port. Default is 22
PORT_SSH="22"


# Enable IPv4 forwarding in Linux kernel
sysctl -w net.ipv4.ip_forward=1

# Create bridge for local subnet
ip link add name $BRIDGE_NAME type bridge

# Set pre-defined MAC address for bridge. Optional.
ip link set dev $BRIDGE_NAME address $BRIDGE_MAC

# Set proper GW address on the bridge 
ip a a $BRIDGE_LAN_IP/$BRIDGE_LAN_MASK dev $BRIDGE_NAME

# Turn ON bridge
ip link set dev $BRIDGE_NAME up

# Add ethernet interface to the bridge
ip link set dev $IFACE_ETH master $BRIDGE_NAME


# Add routing rules for the local network (bridge br_rpi)
ip rule add from all iif $BRIDGE_NAME lookup 14
ip rule add from all iif $BRIDGE_NAME lookup main
ip rule add from $BRIDGE_LAN_IP lookup 14


# Block any input traffic to the router (laptop :D)
iptables -P INPUT DROP

# Allow only SSH connection from management network 
iptables -A INPUT -p tcp -m tcp --dport $PORT_SSH -j ACCEPT
iptables -A OUTPUT -p tcp --sport $PORT_SSH -m state --state ESTABLISHED -j ACCEPT

# Accept traffic on loopback interface
iptables -A INPUT -i lo -j ACCEPT

# Allow input traffic from the local bridge
iptables -A INPUT -i $BRIDGE_NAME -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Proper routing process require masquarading for WAN interface.
iptables -t nat -A POSTROUTING -o $IFACE_WIFI -j MASQUERADE

# Forwarding traffic from WAN interface to the LAN bridge
iptables -A FORWARD -i $IFACE_WIFI -o $BRIDGE_NAME -m state --state RELATED,ESTABLISHED -j ACCEPT

# Forwarding traffic from LAN bridge to WAN interface
iptables -A FORWARD -i $BRIDGE_NAME -o $IFACE_WIFI -j ACCEPT

