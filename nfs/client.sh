#!/bin/bash

# Update and get IP address
sudo apt update
client_ip=$(hostname -I | cut -d' ' -f1)
echo "Client IP: $client_ip"

# Install NFS common package
sudo apt install nfs-common -y

# Create mount point
sudo mkdir -p /nfs

# Read host IP from user input
read -p "Enter the host IP address: " host_ip

# Mount NFS share with host IP
sudo mount "$host_ip":/nfs /nfs

# Check mount status
df -h | grep '/nfs'

echo "NFS client setup completed successfully!"

