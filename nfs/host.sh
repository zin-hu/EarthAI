#!/bin/bash

# Update and get IP address
sudo apt update
host_ip=$(hostname -I | cut -d' ' -f1)
echo "Host IP: $host_ip"

# Install NFS kernel server
sudo apt install nfs-kernel-server -y

# Change directory ownership
sudo chown nobody:nogroup /nfs

# Read client IPs from user input
read -p "Enter the client IP addresses separated by space: " client_ips

# Create an array from the input
IFS=' ' read -ra client_ips_array <<<"$client_ips"

# Build the exports file content
exports_content=""
for client_ip in "${client_ips_array[@]}"; do
    exports_content+="$client_ip(rw,sync,no_subtree_check) "
done

# Edit exports file with client IPs
sudo bash -c "cat << EOF > /etc/exports
/nfs    ${exports_content::-1}
EOF"

# Restart NFS server
sudo systemctl restart nfs-kernel-server

echo "NFS host setup completed successfully!"

