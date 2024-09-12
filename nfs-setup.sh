#!/bin/bash

# Function to install NFS packages
install_nfs() {
    echo ""
    echo "Installing NFS packages..."
    yum install -y nfs-utils firewalld
    systemctl enable --now firewalld
    systemctl enable --now nfs-server
    echo ""
}

# Configure the firewall
configure_firewall() {
    echo "Configuring firewall for NFS..."
    firewall-cmd --permanent --add-service=nfs
    firewall-cmd --permanent --add-service=rpc-bind
    firewall-cmd --permanent --add-service=mountd
    firewall-cmd --reload
    echo ""
}

# Function to prompt for directory and validate its existence
get_valid_directory() {
    local attempts=0
    local max_attempts=3

    while [ $attempts -lt $max_attempts ]; do
        read -p "Enter the full path of the directory you want to share: " dir_path
        echo ""

        if [ -d "$dir_path" ]; then
            echo "Directory is valid."
            return 0  # Directory is valid, exit the function
        else
            echo "Directory does not exist. Please try again."
            ((attempts++))
            echo "Attempt $attempts/$max_attempts."
        fi
    done

    echo "Maximum attempts reached. Exiting the script."
    exit 1
}

# Function to calculate the correct network ID from IP
get_network_id() {
    local ip_address="$1"
    local netmask=$(echo "$ip_address" | awk -F'/' '{print $2}')
    local network=$(echo "$ip_address" | awk -F'.' '{print $1"."$2"."$3".0"}')
    echo "$network/$netmask"
}

# Function to prompt for a valid network interface
get_valid_interface() {
    local attempts=0
    local max_attempts=3
    local default_interface="enp0s8"  # Set the default interface

    while [ $attempts -lt $max_attempts ]; do
        ip -o link show | awk -F': ' '{print $2}'
        echo ""
        read -p "Enter the network interface to use (e.g., enp0s8): " net_interface
        echo ""

        # Check if the interface exists
        if ip link show "$net_interface" &>/dev/null; then
            echo "Network interface is valid."
            local ip_address=$(ip -o -f inet addr show $net_interface | awk '/scope global/ {print $4}')
            NETWORK_ID=$(get_network_id "$ip_address")
            echo "Using Network ID: $NETWORK_ID"
            return 0  # Interface is valid, exit the function
        else
            echo "Network interface does not exist. Please try again."
            ((attempts++))
            echo "Attempt $attempts/$max_attempts."
        fi
    done

    echo "Maximum attempts reached. Using default interface $default_interface."
    local ip_address=$(ip -o -f inet addr show $default_interface | awk '/scope global/ {print $4}')
    NETWORK_ID=$(get_network_id "$ip_address")
    echo "Using Network ID: $NETWORK_ID"
}

# Configure the NFS server
configure_nfs() {
    get_valid_directory  # Get a valid directory path from the user

    read -p "Do you want to share this directory with read-write permissions? (y/n): " rw_permission
    echo ""

    if [ "$rw_permission" == "y" ]; then
        permissions="rw"
    else
        permissions="ro"
    fi

    get_valid_interface  # Get a valid network interface from the user or default

    echo "Configuring NFS exports..."
    echo "$dir_path $NETWORK_ID($permissions,sync,no_root_squash)" >> /etc/exports
    exportfs -rav
    echo ""

    echo "Restarting NFS services..."
    systemctl restart nfs-server
    echo ""
}

# Provide mount instructions for clients
mount_instructions() {
    echo "========================= NFS Setup Completed ========================="
    echo "To mount this directory on other hosts, follow these instructions:"
    echo ""
    echo "1. Install NFS on the client machine using:"
    echo "   sudo yum install -y nfs-utils"
    echo ""
    echo "2. Create a mount directory on the client, for example:"
    echo "   sudo mkdir -p /mnt/nfs_share"
    echo ""
    echo "3. Mount the shared directory using:"
    echo "   sudo mount <SERVER_IP>:$dir_path /mnt/nfs_share"
    echo ""
    echo "4. To make the mount permanent, add the following line to /etc/fstab:"
    echo "   <SERVER_IP>:$dir_path /mnt/nfs_share nfs defaults 0 0"
    echo "========================================================================"
    echo ""
}

# Main script starts here
echo "========================= Starting NFS Server Setup ========================="
echo ""

install_nfs
configure_firewall
configure_nfs
mount_instructions

echo "NFS server configuration completed successfully."

