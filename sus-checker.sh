#!/bin/bash

# Function to display error message and exit
function display_error() {
  echo "Error: $1"
  exit 1
}

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
  display_error "This script must be run as root (superuser)."
fi

# Get the current user
current_user=$(whoami)

# Get the IP address of the machine
ip_address=$(hostname -I)

# Create a log file for network connections
touch network_connections.log

# Function to check and display connections by protocol
function check_connections() {
  local protocol="$1"
  local connections=$(netstat -an | grep -E "$protocol|LISTEN")
  if [[ -n $connections ]]; then
    echo "Found $protocol connection(s):"
    echo "$connections"
    # Log connections to a file for later analysis
    echo "$connections" >> network_connections.log
  fi
}

# Check for SSH connections
check_connections "ssh"

# Check for RDP connections
check_connections "rdp"

# Check for other remote connections
check_connections "tcp" | grep -vE "ssh|rdp"

# Check for suspicious connections
suspicious_connections=$(netstat -an | grep -E "0\.0\.0\.0:|127\.0\.0\.1:")
if [[ -n $suspicious_connections ]]; then
  echo "Found suspicious connection(s):"
  echo "$suspicious_connections"
  # Log suspicious connections to a file for later analysis
  echo "$suspicious_connections" >> suspicious_connections.log
fi

# Clean exit
exit 0
