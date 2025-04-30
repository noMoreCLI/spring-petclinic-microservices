#!/bin/bash
#
# Setup script for MicroK8s for Cisco Live Lab
#
USER_NAME="${USER_NAME:-cisco}"
echo "Setting Hostname"
hostnamectl set-hostname microk8s

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
apt install -y retry snapd git wget curl

echo "198.18.134.22    ansible" >> /etc/hosts
echo "198.18.134.25    petclinic-db" >> /etc/hosts
echo "198.18.134.24    visits-service" >> /etc/hosts


echo "Installing MicroK8s"
retry snap install microk8s --classic --channel=1.32/stable
microk8s enable dns:8.8.8.8,8.8.4.4
microk8s enable metallb:198.18.134.23-198.18.134.23
usermod -a -G microk8s ${USER_NAME}
echo "Wait for microk8s to be ready ..."
microk8s status --wait-ready
echo "Installing kubectl"
snap alias microk8s.kubectl kubectl
mkdir /root/.kube
mkdir /home/${USER_NAME}/.kube
microk8s config > /root/.kube/config
microk8s config > /home/${USER_NAME}/.kube/config
chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.kube

echo "Installing Helm"
microk8s enable helm3
snap alias microk8s.helm3 helm

echo "Installing K9s"
wget https://github.com/derailed/k9s/releases/download/v0.50.4/k9s_linux_amd64.deb 
dpkg -i k9s_linux_amd64.deb
rm k9s_linux_amd64.deb

echo "Cloning CL2025 US Lab Repository for user: ${USER_NAME}"
su - ${USER_NAME} -c "git clone --branch cl25us --depth 1 https://github.com/noMoreCLI/spring-petclinic-microservices.git"

echo "Deploying Pet Clinic"


echo "Setup Done"
