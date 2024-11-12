
---

# Smart DNS Proxy

Smart DNS Proxy is a DNS-based solution to help you access geographically restricted streaming content from various VOD (Video on Demand) providers worldwide. With this Smart DNS solution, you can bypass geographic restrictions on popular streaming platforms without using a VPN, providing better speeds and no data throttling.

### Features
- Unlock access to global streaming content.
- Faster connection compared to VPNs as traffic is routed only through necessary domains.
- Easy setup using Docker, making it deployable across various environments.

### Supported Video on Demand (VOD) Providers
The following VOD providers are known to be compatible with this Smart DNS Proxy setup:
- **Netflix**
- **Hulu**
- **Disney+**
- **Amazon Prime Video**
- **HBO Max**
- **BBC iPlayer**
- **Peacock**
- **Paramount+**
- **Showtime**
- **Starz**
- **Apple TV+**
- **Crunchyroll**
- **Sling TV**
- **FuboTV**
- **DAZN**
- **Roku Channel**
- **Plex**
- **Samsung TV Plus**

Please note that this solution may not work on all VOD providers or might require specific regional configurations for certain platforms.

---

## Installation Instructions

This project is designed to work on **Ubuntu** or **Debian** distributions. Please ensure your system meets the following requirements:

- **Supported OS**: Ubuntu or Debian (or other distributions that support Docker and Docker Compose)
- **Network Interface**: Ensure that you know the correct network interface (e.g., `eth0`) for your server setup.
  
### Quick Start

To get started, clone this repository and use the provided installer script. The installation script automates the setup by installing dependencies, configuring Docker, and deploying the Smart DNS Proxy with Docker Compose.

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/cryptroute/smart-dns-proxy
    cd smart-dns-proxy
    ```

2. **Run the Installer**:
    The installer script will handle the entire installation process, including checking for prerequisites, configuring Docker, and setting up Docker Compose. 

    ```bash
    chmod +x install_smart_dns.sh
    sudo ./install_smart_dns.sh
    ```

### Installation Script Guide

The installation script (`install_smart_dns.sh`) will:
1. Check if the operating system is Ubuntu or Debian. If not, it will stop the installation.
2. Prompt you to confirm the installation.
3. Ask you to provide:
   - **IP address** for DNS proxying.
   - **Network interface** (e.g., `eth0`).
4. Check if Docker and Docker Compose are installed. If not, it will install them.
5. Install additional required tools: `net-tools`, `nano`, `git`, and `lsof`.
6. Disable `systemd-resolved` if active to free up port 53, which is required by `dnsmasq`.
7. Modify `/etc/resolv.conf` to use Google DNS (`8.8.8.8`) for the local system.
8. Restart Docker to apply any changes.
9. Configure `docker-compose.yml` with the provided IP address and network interface.
10. Run `docker-compose up -d` to start the Smart DNS Proxy service.

---

## Configuration

The `docker-compose.yml` file is configured to use the Docker `host` network mode, allowing it to access host network interfaces directly. The installer script automatically updates `docker-compose.yml` with your input values for the IP address and network interface.

If you need to make adjustments after installation, edit `docker-compose.yml` directly.

## Troubleshooting

- **Port 53 Conflict**: Ensure no other services (e.g., `systemd-resolved`) are using port 53 on the host.
- **Container Issues**: Check container logs for errors:
    ```bash
    docker logs cryptroute-dns-proxy
    ```
- **Access Issues**: Ensure that the correct IP and network interface are configured in `docker-compose.yml`.

## Uninstalling

To remove Smart DNS Proxy, follow these steps:

1. **Stop and Remove Containers**:
    ```bash
    cd smart-dns-proxy
    docker-compose down
    ```

2. **Remove Docker Images (Optional)**:
    ```bash
    docker rmi cryptroute/cryptroute-dns-proxy:latest
    ```

3. **Restore System Resolver**:
    If you modified `/etc/resolv.conf`, restore it to use your default DNS (e.g., `systemd-resolved`):
    ```bash
    sudo systemctl enable systemd-resolved
    sudo systemctl start systemd-resolved
    ```

---

## Known Limitations

- **Geo-blocked Content**: While the Smart DNS Proxy enables access to many VOD services, some providers may still enforce additional geo-blocking measures that this DNS proxy alone may not bypass.
- **Network Restrictions**: This solution assumes an open network environment. Firewalls and additional security policies may require adjustments to allow DNS traffic through the designated ports.

## Contributions

Contributions, issues, and feature requests are welcome. Feel free to fork this repository and submit pull requests to improve the project.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

---

This `README.md` provides comprehensive information on installation, configuration, and usage, helping any user to quickly set up and manage the Smart DNS Proxy.
