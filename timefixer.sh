#!/bin/bash

# Auther: Kris Tomplait
# This script was originally made with the intention to fix my time clock on the laptop
# but I was far to lazy to just look it up everytime.. normally
# I won't even bother but I figured I would just get this out of the way
# so as usual, us this at your own risk.....



# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Function to check and install required packages
check_and_install_dependencies() {
  local packages=("$@")
  for package in "${packages[@]}"; do
    if ! dpkg -l | grep -q "ii  $package"; then
      echo "Installing $package..."
      apt-get install -y "$package"
      if [ $? -ne 0 ]; then
        echo "Error: Failed to install $package. Exiting..."
        exit 1
      else
        echo "$package installed successfully."
      fi
    else
      echo "$package is already installed."
    fi
  done
}

# Check and install required packages (curl and wget)
required_packages=("curl" "wget")
echo "Checking and installing required packages..."
check_and_install_dependencies "${required_packages[@]}"

# Synchronize system clock
echo "Synchronizing system clock..."
timedatectl set-ntp true
sleep 5

# Set the system date and time using an external time API
echo "Setting system date and time..."
time_api="https://www.timeapi.org/utc/time"
system_time=""

# Try using curl
if command -v curl >/dev/null; then
  echo "Using curl to retrieve time from the time API..."
  system_time=$(curl -s "$time_api")
fi

# If curl fails, try using wget
if [[ -z $system_time ]] && command -v wget >/dev/null; then
  echo "Using wget to retrieve time from the time API..."
  system_time=$(wget -qO- "$time_api")
fi

# If both curl and wget fail, display an error message
if [[ -z $system_time ]]; then
  echo "Error: Failed to retrieve system time from the time API. Exiting..."
  exit 1
else
  echo "System time retrieved successfully: $system_time"
fi

# Set the system time
timedatectl set-time "$system_time"
echo "System time set successfully."

# Update and upgrade the system
echo "Updating and upgrading the system..."
apt-get update
apt-get upgrade -y
echo "System updated and upgraded successfully."

echo "Script execution completed successfully."
exit 0
