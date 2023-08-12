#!/bin/bash


# Author: Kris Tomplait
# Use at your own risk.... it was made by me...
# what could go wrong???

# Clear the terminal
clear

# Define log files
auth_log="/var/log/auth.log"
sys_log="/var/log/syslog"
output_log="/var/log/security_check.log"

# Maximum log file size (in MB)
max_log_size=10

# Check if log files exist
check_log_files() {
  if [[ ! -f "$auth_log" || ! -f "$sys_log" ]]; then
    echo "Error: Required log files not found."
    exit 1
  fi
}

# Log suspicious activity
log_activity() {
  echo "[Suspicious Activity] $(date '+%Y-%m-%d %H:%M:%S') - User: $user" >> "$output_log"
  echo "$line" >> "$output_log"
}

# Perform log rotation
perform_log_rotation() {
  if [[ -f "$output_log" && $(du -m "$output_log" | cut -f 1) -ge "$max_log_size" ]]; then
    mv "$output_log" "$output_log.$(date '+%Y%m%d%H%M%S')"
  fi
}

# Check for remote SSH logins
check_remote_ssh_logins() {
  grep -E "sshd.*Accepted.*from" "$auth_log" | while read -r line; do
    remote_ip=$(echo "$line" | grep -oE "from \[[:digit:]\.]+\]" | cut -d "[" -f 2 | cut -d "]" -f 1)
    if [[ $remote_ip != 127.0.0.1 ]]; then
      log_activity
    fi
  done
}

# Check for suspicious file changes
check_suspicious_file_changes() {
  grep "-rw-r--r--.*root.*\/etc\/" "$sys_log" | while read -r line; do
    log_activity
  done
}

# Check for unauthorized user or group creation
check_unauthorized_user_group_creation() {
  grep "useradd.*root" "$sys_log" | while read -r line; do
    log_activity
  done
}

# Main function for security checks
perform_security_checks() {
  check_log_files
  users=$(who | awk '{print $1}')
  
  # Perform log rotation before starting checks
  perform_log_rotation

  for user in $users; do
    echo "Checking user: $user - $(date '+%Y-%m-%d %H:%M:%S')"
  
    if [[ "$user" == "ssh" ]]; then
      echo "User $user logged in from a remote location."
    fi

    if grep -q "$user" /etc/sudoers; then
      echo "User $user is in the sudoers file."
    fi

    if [[ -f "$auth_log" ]]; then
      check_remote_ssh_logins
    fi

    if [[ -f "$sys_log" ]]; then
      check_suspicious_file_changes
      check_unauthorized_user_group_creation
    fi

    # Add more checks here if needed

  done

  echo "Security checks completed. Summary:"
  if [[ -f "$output_log" ]]; then
    cat "$output_log"
  else
    echo "No suspicious activity found."
  fi
}

# Run the security checks
perform_security_checks
