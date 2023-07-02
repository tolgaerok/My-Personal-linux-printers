#!/bin/bash
# Tolga Erok 29 June 2023

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Get the username of the current user
current_user=$(logname)

# Check if the current user is already in sudoers
if grep -q "^$current_user" /etc/sudoers; then
    echo "User $current_user is already in the sudoers file."
    exit 0
fi

# Backup the sudoers file
cp /etc/sudoers /etc/sudoers.backup

# Add the current user to sudoers
echo "$current_user    ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Verify if the modification was successful
if [ $? -eq 0 ]; then
    echo "User $current_user has been added to the sudoers file successfully."
else
    echo "Failed to add user $current_user to the sudoers file."
    # Restore the backup
    mv /etc/sudoers.backup /etc/sudoers
fi
