#!/bin/bash
#
# Setup script for MySql Server for Cisco Live Lab
#
USER_NAME="${USER_NAME:-cisco}"
USER_PASSWORD="${USER_PASSWORD:-C1sco12345}"
ROOT_PASSWORD="${ROOT_PASSWORD:-C1sco12345}"
echo "Setting Hostname"
hostnamectl set-hostname visits-service

echo "Setting Password for root"
echo "root:${ROOT_PASSWORD}" | chpasswd

echo "Creating Cisco User"
useradd -m -s /bin/bash ${USER_NAME}
echo "Setting Password for ${USER_NAME}"
echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd
echo "Adding ${USER_NAME} to sudo group"
usermod -aG sudo ${USER_NAME}

echo "Adding hosts entries"
echo "198.18.134.22    ansible" >> /etc/hosts
echo "198.18.134.25    petclinic-db" >> /etc/hosts
echo "198.18.134.25    petclinic-db" >> /etc/hosts
echo "198.18.134.23    config-server discovery-server customers-service vets-service admin-service genai-service api-gateway notification-service" >> /etc/hosts

echo "Updateing System"
apt update && apt upgrade -y
apt install -y retry snapd git wget curl mysql-client ca-certificates openjdk-17-jdk

echo "Cloning CL2025 US Lab Repository for user: ${USER_NAME}"
su - ${USER_NAME} -c "git clone --branch cl25us --depth 1 https://github.com/noMoreCLI/spring-petclinic-microservices.git" 