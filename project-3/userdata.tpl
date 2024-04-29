#!/bin/bash

# Update existing packages
sudo yum update -y

# Install required packages to enable yum to use repositories over HTTPS
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# Add Docker repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Start Docker service
sudo systemctl start docker

# Enable Docker service to start on boot
sudo systemctl enable docker

# Install Docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Apply executable permissions to Docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo usermod -aG docker ec2-user

# Verify Docker and Docker-compose installation
docker --version
docker-compose --version