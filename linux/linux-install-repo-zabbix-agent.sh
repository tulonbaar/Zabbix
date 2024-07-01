#!/bin/bash

# Function to uninstall Zabbix Agent if it exists
uninstall_zabbix() {
    if dpkg -l | grep -q zabbix-agent; then
        echo "Zabbix Agent is installed. Uninstalling..."
        sudo apt-get remove --purge zabbix-agent -y
    fi

    if dpkg -l | grep -q zabbix-agent2; then
        echo "Zabbix Agent 2 is installed. Uninstalling..."
        sudo apt-get remove --purge zabbix-agent2 -y
    fi
}

# Function to add Zabbix repository based on Ubuntu version
add_zabbix_repo() {
    echo "Adding Zabbix repository for Ubuntu $UBUNTU_VERSION..."
    case $UBUNTU_VERSION in
        22.04)
            wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu22.04_all.deb
            dpkg -i zabbix-release_7.0-1+ubuntu22.04_all.deb
            echo "deb https://repo.zabbix.com/zabbix/7.0/ubuntu jammy main" | sudo tee /etc/apt/sources.list.d/zabbix.list > /dev/null
            echo "deb-src https://repo.zabbix.com/zabbix/7.0/ubuntu jammy main" | sudo tee -a /etc/apt/sources.list.d/zabbix.list > /dev/null
            ;;
        24.04)
            wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu24.04_all.deb
            dpkg -i zabbix-release_7.0-1+ubuntu24.04_all.deb
            echo "deb https://repo.zabbix.com/zabbix/7.0/ubuntu noble main" | sudo tee /etc/apt/sources.list.d/zabbix.list > /dev/null
            echo "deb-src https://repo.zabbix.com/zabbix/7.0/ubuntu noble main" | sudo tee -a /etc/apt/sources.list.d/zabbix.list > /dev/null
            ;;
        20.04)
            wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu20.04_all.deb
            dpkg -i zabbix-release_7.0-1+ubuntu20.04_all.deb
            echo "deb https://repo.zabbix.com/zabbix/7.0/ubuntu focal main" | sudo tee /etc/apt/sources.list.d/zabbix.list > /dev/null
            echo "deb-src https://repo.zabbix.com/zabbix/7.0/ubuntu focal main" | sudo tee -a /etc/apt/sources.list.d/zabbix.list > /dev/null
            ;;
        18.04)
            wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu18.04_all.deb
            dpkg -i zabbix-release_7.0-1+ubuntu18.04_all.deb
            echo "deb https://repo.zabbix.com/zabbix/7.0/ubuntu bionic main" | sudo tee /etc/apt/sources.list.d/zabbix.list > /dev/null
            echo "deb-src https://repo.zabbix.com/zabbix/7.0/ubuntu bionic main" | sudo tee -a /etc/apt/sources.list.d/zabbix.list > /dev/null
            ;;
        *)
            echo "Unsupported Ubuntu version."
            exit 1
            ;;
    esac
    sudo apt update
}

# Function to install Zabbix Agent 2 and its plugins
install_zabbix_agent2() {
    echo "Installing Zabbix Agent 2 and its plugins..."
    sudo apt install zabbix-agent2 zabbix-agent2-plugin-* -y
}

# Function to update or add a configuration line
update_or_add_line() {
    local key="$1"
    local value="$2"
    local file="$3"

    # Check if the line exists and contains the key
    if grep -qE "^$key" "$file"; then
        # Line exists, update it
        sed -i "s/^$key.*/$key$value/" "$file"
    else
        # Line does not exist, add it
        echo "$key$value" >> "$file"
    fi
}

# Main script starts here
UBUNTU_VERSION=$(lsb_release -rs)

# Uninstall existing Zabbix Agent versions
uninstall_zabbix

# Add Zabbix repository
add_zabbix_repo

# Install Zabbix Agent 2 and its plugins
install_zabbix_agent2

echo "Zabbix Agent 2 and its plugins installation completed."

# Configuration file path
CONFIG_FILE="/etc/zabbix/zabbix_agent2.conf"

# System hostname
HOSTNAME=$(hostname)

# Update or add the required configuration lines
update_or_add_line "Server=" "<zabbix-server-address>" "$CONFIG_FILE"
update_or_add_line "ServerActive=" "<zabbix-server-address>" "$CONFIG_FILE"
update_or_add_line "Hostname=" "$HOSTNAME" "$CONFIG_FILE"
update_or_add_line "AllowKey=" "system.run[*]" "$CONFIG_FILE"

# Check if Zabbix Agent 2 is running
serviceStatus=$(systemctl is-active zabbix-agent2)

if [ "$serviceStatus" = "active" ]; then
    echo "Zabbix Agent 2 is running. Restarting it..."
    sudo systemctl restart zabbix-agent2
else
    echo "Zabbix Agent 2 is not running. Starting it..."
    sudo systemctl start zabbix-agent2
fi

echo "Zabbix Agent 2 restart completed."

echo "Zabbix Agent 2 configuration updated."
