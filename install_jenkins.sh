#!/bin/bash

# this script is only tested on ubuntu focal 20.04 (LTS)

# Step 1: Install Docker
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to the Docker group
sudo usermod -aG docker $USER
echo "Please log out and log back in to apply Docker group changes."

# Step 2: Run Jenkins in Docker

# Create Jenkins home directory with proper permissions
mkdir -p /var/jenkins_home
sudo chown -R 1000:1000 /var/jenkins_home/

# Run Jenkins container with Docker socket mounted for Docker integration
docker run -p 8080:8080 -p 50000:50000 -v /var/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock -d --name jenkins jenkins/jenkins:lts

# Step 3: Show Jenkins access details

# Show Jenkins endpoint
echo "Jenkins installed. You can access it at: http://$(curl -4 -s ifconfig.co):8080"

# Show Jenkins initial admin password
echo "Jenkins initial admin password:"
docker exec $(docker ps -q -f name=jenkins) cat /var/jenkins_home/secrets/initialAdminPassword