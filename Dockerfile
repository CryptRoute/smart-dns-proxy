# Base Image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y nginx dnsmasq && \
    apt-get clean

# Copy configuration files and startup script
COPY nginx.conf /etc/nginx/nginx.conf
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY proxy.conf /etc/dnsmasq.d/proxy.conf
COPY start.sh /start.sh

# Set the startup script as the entrypoint
ENTRYPOINT ["/start.sh"]

# Expose necessary ports
EXPOSE 80 443 53/udp 53/tcp
