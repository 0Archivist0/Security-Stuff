#!/bin/bash

# Function to exit the script with a clean exit
clean_exit() {
  echo "---------------------------------------"
  echo "remote connections: $remote_conn_count"
  echo "ssh: $ssh_conn_count"
  echo "active connections: $active_conn_count"
  echo "---------------------------------------"
  echo "Users: $total_users"
  echo "logged in: $logged_in_users"
  echo "---------------------------------------"
  echo "$(date) - Exiting..."
  exit 0
}

# Function to handle errors and exit the script
handle_error() {
  local exit_status=$1
  echo "$(date) - An error occurred. Exiting..."
  echo "$(date) - An error occurred. Exiting..." >> error.log
  echo "$(date) - Command that failed: $prev_command" >> error.log
  exit "$exit_status"
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "$(date) - This script must be run with root privileges."
  exit 1
fi

# Clear the screen
prev_command="clear"
clear || handle_error $?

# Print the current and previous users
echo "$(date) - Current users:"
prev_command="who"
who || handle_error $?
echo "$(date) - Previous users:"
prev_command="last"
last -n 5 || handle_error $?

# Count active SSH and remote connections
echo "$(date) - Counting active SSH or remote connections:"
prev_command="netstat"
remote_conn_count=$(netstat -an | grep ":22" | wc -l)
ssh_conn_count=$(netstat -an | grep ":22" | grep "ESTABLISHED" | wc -l)
active_conn_count=$(($remote_conn_count + $ssh_conn_count))

# Check for other user accounts
current_user=$(whoami)
prev_command="awk"
other_users=$(awk -F':' -v current="$current_user" '$1 != current { print $1 }' /etc/passwd)
total_users=$(awk -F':' '{ print $1 }' /etc/passwd | wc -l)
logged_in_users=$(who | wc -l)

if [[ -z $other_users ]]; then
  echo "$(date) - No other user accounts found."
else
  echo "$(date) - Other user accounts:"
  echo "$other_users"
fi

# Display formatted information
clean_exit
