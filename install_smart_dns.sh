#!/bin/bash
clear
# Display information about the script
echo "Smart DNS Proxy Installer"
echo "This script installs Smart DNS Proxy with Docker and Docker Compose."
echo "Supported OS: Ubuntu, Debian"
echo ""

# Set DEBIAN_FRONTEND to noninteractive to suppress prompts
export DEBIAN_FRONTEND=noninteractive

# Configure needrestart to automatically handle restarts
echo "Configuring needrestart to automatically restart services..."
sudo bash -c 'echo "\$nrconf{restart} = '\''a'\'';" > /etc/needrestart/needrestart.conf'

# Check if the OS is Ubuntu or Debian
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
    echo "This installer is only supported on Ubuntu or Debian."
    echo "Detected OS: $NAME"
    exit 1
  fi
else
  echo "Cannot determine OS. This installer is only supported on Ubuntu or Debian."
  exit 1
fi

# Prompt the user to proceed
read -p "Do you want to proceed with the installation? (Y/N): " choice
if [[ "$choice" != "Y" && "$choice" != "y" ]]; then
  echo "Installation cancelled."
  exit 1
fi

# Prompt for IP Address and Network Interface
read -p "Enter the IP address to use for DNS Proxy: " DNS_SERVER_IP
read -p "Enter the network interface (e.g., eth0): " NETWORK_INTERFACE

# Function to check if a package is installed and install if missing
function install_if_missing() {
  if ! dpkg -s "$1" &> /dev/null; then
    echo "Installing $1..."
    sudo apt-get install -y "$1"
  else
    echo "$1 is already installed."
  fi
}

# Check if Docker is installed, with separate handling for Debian
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed. Installing Docker..."

  # Update package list
  sudo apt-get update

  # Set up Docker repository for Debian if needed
  if [[ "$ID" == "debian" ]]; then
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  else
    # For Ubuntu
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  fi

  # Update package list after adding Docker repository
  sudo apt-get update

  # Install Docker CE
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

  # Enable and start Docker service
  sudo systemctl enable docker
  sudo systemctl start docker
  echo "Docker installed successfully."
else
  echo "Docker is already installed."
fi

# Check and install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
  echo "Docker Compose is not installed. Installing Docker Compose..."
  # Download the latest stable version of docker-compose
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Create a symlink to ensure it’s accessible globally
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

  echo "Docker Compose installed successfully."
else
  echo "Docker Compose is already installed."
fi

# Check and install additional required tools
install_if_missing "net-tools"
install_if_missing "nano"
install_if_missing "git"
install_if_missing "lsof"

# Check if systemd-resolved is active and disable if necessary
if systemctl is-active --quiet systemd-resolved; then
  echo "systemd-resolved is active. Disabling and stopping it to free port 53..."
  sudo systemctl disable systemd-resolved
  sudo systemctl stop systemd-resolved
  sudo rm /etc/resolv.conf
  echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
  sudo chattr +i /etc/resolv.conf
fi

# Restart Docker to ensure it's running and updated
echo "Restarting Docker..."
sudo systemctl restart docker
clear
# Edit docker-compose.yml with provided IP address and network interface
echo "Configuring docker-compose.yml with the provided IP and network interface..."
sed -i "s/<DNS_SERVER_IP>/$DNS_SERVER_IP/g" docker-compose.yml
sed -i "s/<NETWORK_INTERFACE>/$NETWORK_INTERFACE/g" docker-compose.yml

# Start the service with Docker Compose
echo "Starting Smart DNS Proxy with Docker Compose..."
docker-compose up -d

# Check if the container is running successfully
container_status=$(docker ps --filter "name=cryptroute-dns-proxy" --format "{{.Status}}")
if [[ "$container_status" == *"Up"* ]]; then
  echo "Smart DNS Proxy is up and running successfully!"
  echo "You should now point your DNS to $DNS_SERVER_IP to unblock services."
else
  echo "There was an error starting Smart DNS Proxy. Here are the last logs:"
  docker logs cryptroute-dns-proxy
  echo "Please check the logs above and try again."
  exit 1
fi
