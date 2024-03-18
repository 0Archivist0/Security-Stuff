#!/bin/bash

# Function to check if adb is installed and install if necessary
check_adb_installed() {
    if ! command -v adb &> /dev/null; then
        echo "ADB is not installed. Installing adb..."
        sudo apt update
        sudo apt install adb
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install adb. Please install it manually."
            exit 1
        fi
    fi
}

# Function to check if the user has proper permissions
check_permissions() {
    adb devices &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: You do not have proper permissions to use adb."
        echo "Please ensure adb is properly set up and you have the necessary permissions."
        exit 1
    fi
}

# Function to scan USB ports for connected devices and display selectable devices
scan_devices() {
    echo "Scanning USB ports for connected devices..."
    devices=$(adb devices | awk 'NR>1{print $1}')
    if [ -z "$devices" ]; then
        echo "No devices found connected via USB."
        exit 1
    else
        echo "List of devices connected via USB:"
        echo "$devices"
    fi
}

# Function to execute adb command
execute_adb_command() {
    read -p "Enter the adb command you want to execute: " adb_cmd
    adb -s "$selected_device" "$adb_cmd"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to execute adb command: $adb_cmd"
    fi
}

# Function to backup device data
backup_device() {
    echo "Backing up device data..."
    adb -s "$selected_device" backup -all -f device_backup.ab
    if [ $? -eq 0 ]; then
        echo "Device data backup successful."
    else
        echo "Error: Failed to backup device data."
    fi
}

# Function to restore device data
restore_device() {
    echo "Restoring device data..."
    adb -s "$selected_device" restore device_backup.ab
    if [ $? -eq 0 ]; then
        echo "Device data restore successful."
    else
        echo "Error: Failed to restore device data."
    fi
}

# Function to install APK
install_apk() {
    read -p "Enter the path to the APK file you want to install: " apk_path
    adb -s "$selected_device" install "$apk_path"
    if [ $? -eq 0 ]; then
        echo "APK installation successful."
    else
        echo "Error: Failed to install APK."
    fi
}

# Function to reboot the device
reboot_device() {
    echo "Select a reboot option:"
    echo "1. Reboot device"
    echo "2. Reboot into recovery mode"
    echo "3. Reboot into bootloader mode"
    read -p "Enter your choice: " reboot_option
    case $reboot_option in
        1 )
            adb -s "$selected_device" reboot
            ;;
        2 )
            adb -s "$selected_device" reboot recovery
            ;;
        3 )
            adb -s "$selected_device" reboot bootloader
            ;;
        * )
            echo "Invalid choice. Reboot aborted."
            ;;
    esac
}

# Function to take a screenshot
take_screenshot() {
    echo "Taking a screenshot..."
    adb -s "$selected_device" shell screencap -p /sdcard/screenshot.png
    adb -s "$selected_device" pull /sdcard/screenshot.png
    if [ $? -eq 0 ]; then
        echo "Screenshot saved as screenshot.png"
    else
        echo "Error: Failed to take screenshot."
    fi
}

# Main function
main() {
    echo "Welcome to the adb automation script!"
    echo "This script will help you interact with connected Android devices via adb."

    # Check adb installation and install if necessary
    check_adb_installed

    # Check permissions
    check_permissions

    # Submenu for main actions
    while true; do
        echo "Select an option:"
        echo "1. Device Actions"
        echo "2. Execute adb command"
        echo "3. Exit"
        read -p "Enter your choice: " main_choice
        case $main_choice in
            1 )
                # Submenu for device actions
                while true; do
                    echo "Select a device action:"
                    echo "1. Scan USB ports for connected devices"
                    echo "2. Backup device data"
                    echo "3. Restore device data"
                    echo "4. Install APK"
                    echo "5. Reboot device"
                    echo "6. Take a screenshot"
                    echo "7. Back to main menu"
                    read -p "Enter your choice: " device_action_choice
                    case $device_action_choice in
                        1 )
                            scan_devices
                            ;;
                        2 )
                            backup_device
                            ;;
                        3 )
                            restore_device
                            ;;
                        4 )
                            install_apk
                            ;;
                        5 )
                            reboot_device
                            ;;
                        6 )
                            take_screenshot
                            ;;
                        7 )
                            break
                            ;;
                        * )
                            echo "Invalid choice. Please enter a valid option."
                            ;;
                    esac
                done
                ;;
            2 )
                execute_adb_command
                ;;
            3 )
                echo "Exiting the adb automation script. Goodbye!"
                exit 0
                ;;
            * )
                echo "Invalid choice. Please enter a valid option."
                ;;
        esac
    done
}

# Execute main function
main
