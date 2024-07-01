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

# Main script starts here
UBUNTU_VERSION=$(lsb_release -rs)

# Uninstall existing Zabbix Agent versions
uninstall_zabbix

# Add Zabbix repository
add_zabbix_repo

# Install Zabbix Agent 2 and its plugins
install_zabbix_agent2

echo "Zabbix Agent 2 and its plugins installation completed."
