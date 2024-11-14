#!/bin/bash

# Replace placeholders with environment variable values
interface=${NETWORK_INTERFACE:-eth0}  # Default to eth0 if not set
dns_ip=${DNS_SERVER_IP:-127.0.0.1}    # Default to 127.0.0.1 if not set

# Update dnsmasq.conf and proxy.conf with the environment values
sed -i "s/{{NETWORK_INTERFACE}}/$interface/g" /etc/dnsmasq.conf
sed -i "s/{{DNS_SERVER_IP}}/$dns_ip/g" /etc/dnsmasq.d/proxy.conf

# Start nginx in the foreground
nginx -g 'daemon off;' &

# Start dnsmasq in the foreground to keep the container running
dnsmasq -k
