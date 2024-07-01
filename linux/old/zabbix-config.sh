#!/bin/bash

# Configuration file path
CONFIG_FILE="/etc/zabbix/zabbix_agent2.conf"

# System hostname
HOSTNAME=$(hostname)

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

# Update or add the required configuration lines
update_or_add_line "Server=" "zabbix.hartphp.com.pl,zabbix-new.hartphp.com.pl" "$CONFIG_FILE"
update_or_add_line "ServerActive=" "zabbix.hartphp.com.pl,zabbix-new.hartphp.com.pl" "$CONFIG_FILE"
update_or_add_line "Hostname=" "$HOSTNAME" "$CONFIG_FILE"
update_or_add_line "AllowKey=" "system.run[*]" "$CONFIG_FILE"

echo "Zabbix Agent 2 configuration updated."
