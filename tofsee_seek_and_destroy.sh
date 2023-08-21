#!/bin/bash

# Function to search for files containing Tofsee malware
search_malware() {
    # Search the file system for files containing Tofsee malware
    result=$(sudo find / -type f -exec grep -l "8121b07538fee52be986b858770edf3ba65724d1bc778fee35f0f3ca821c42b0" {} + 2>/dev/null)

    # If files are found, print the result and their locations
    if [ -n "$result" ]; then
        echo "Tofsee malware found in the following locations:"
        echo "$result"
    else
        echo "Tofsee malware not found!"
        exit 0
    fi
}

# Function to prompt the user for actions related to file deletion
prompt_user() {
    read -p "Do you want to proceed with deleting files containing Tofsee malware? (y/n): " choice

    if [ "$choice" == "y" ]; then
        # Confirm final deletion
        read -p "Are you absolutely sure you want to delete these files? This action cannot be undone. (y/n): " confirm

        if [ "$confirm" == "y" ]; then
            # Delete all files containing Tofsee malware
            for file in $result; do
                if [ -f "$file" ]; then
                    sudo rm -f "$file"
                    echo "Deleted: $file"
                else
                    echo "File not found: $file"
                fi
            done
            echo "All files deleted successfully!"
        else
            echo "Operation cancelled. Leaving the files as they are."
        fi
    else
        echo "No files will be deleted. Exiting."
    fi
}

# Search for Tofsee malware
search_malware

# Prompt the user for actions related to file deletion
prompt_user
