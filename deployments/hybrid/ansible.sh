#!/bin/bash

# Exit on any error
set -e

echo "Starting Ansible installation..."

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install required dependencies
echo "Installing dependencies..."
sudo apt-get install -y software-properties-common

# Install Ansible
echo "Installing Ansible..."
sudo apt-get install -y ansible

# Verify installation
ansible_version=$(ansible --version | head -n1)
echo "Installation completed successfully!"
echo "Installed version: $ansible_version"

# Install K8 ansible collection
ansible-galaxy collection install community.kubernetes

# Install sshpass
# sudo apt-get install -y sshpass

# Install unzip
sudo apt-get install -y unzip
