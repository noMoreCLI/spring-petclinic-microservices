#!/bin/bash
#
# Setup script for MySql Server for Cisco Live Lab
#
USER_NAME="${USER_NAME:-cisco}"
echo "Setting Hostname"
hostnamectl set-hostname petclinic-db

echo "Setting Password for root"
echo "root:C1sco12345" | chpasswd

echo "Creating Cisco User"
useradd -m -s /bin/bash ${USER_NAME}
echo "Setting Password for ${USER_NAME}"
echo "${USER_NAME}:C1sco12345" | chpasswd
echo "Adding ${USER_NAME} to sudo group"
usermod -aG sudo ${USER_NAME}

echo "Updateing System"
apt update && apt upgrade -y
apt install -y retry snapd git wget curl mysql-client ca-certificates

echo "198.18.134.22    ansible" >> /etc/hosts
echo "198.18.134.25    petclinic-db" >> /etc/hosts
echo "198.18.134.24    visits-service" >> /etc/hosts
echo "198.18.134.23    config-server discovery-server customers-service vets-service admin-service genai-service api-gateway" >> /etc/hosts

echo "Installing Docker"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose python3-distutils-extra
usermod -aG docker $USER_NAME

echo "Cloning CL2025 US Lab Repository for user: ${USER_NAME}"
su - ${USER_NAME} -c "git clone --branch cl25us --depth 1 https://github.com/noMoreCLI/spring-petclinic-microservices.git"