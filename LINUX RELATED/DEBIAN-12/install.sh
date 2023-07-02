#!/bin/bash

# Tolga Erok    My personal debian 12 installer
# 28/6/2023

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
    echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
    exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

# Update packages list and update system
apt update
apt upgrade -y

cd $builddir

sudo apt-get install gdebi flatpak firmware-realtek bluez bluez-tools libavcodec-extra vlc samba synaptic cifs-utils gnome-software-plugin-flatpak -y
sudo apt install plocate sntp ntpdate software-properties-common terminator htop neofetch -y
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install flathub com.sindresorhus.Caprine

# Download teamviewer
download_url="https://dl.teamviewer.com/download/linux/version_15x/teamviewer_15.43.6_amd64.deb?utm_source=google&utm_medium=cpc&utm_campaign=au%7Cb%7Cpr%7C22%7Cjun%7Ctv-core-brand-only-exact-sn%7Cfree%7Ct0%7C0&utm_content=Exact&utm_term=teamviewer&ref=https%3A%2F%2Fwww.teamviewer.com%2Fen-au%2Fdownload%2Flinux%2F%3Futm_source%3Dgoogle%26utm_medium%3Dcpc%26utm_campaign%3Dau%257Cb%257Cpr%257C22%257Cjun%257Ctv-core-brand-only-exact-sn%257Cfree%257Ct0%257C0%26utm_content%3DExact%26utm_term%3Dteamviewer"
download_location="/tmp/teamviewer_15.43.6_amd64.deb"

echo "Downloading teamviewer..."
wget -O "$download_location" "$download_url"

# Install Visual Studio Code
echo "Installing teamviwer..."
sudo dpkg -i "$download_location"
sudo apt-get install -f -y

# Cleanup
echo "Cleaning up..."
rm "$download_location"


# Download Visual Studio Code
download_url="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
download_location="/tmp/vscode.deb"

echo "Downloading Visual Studio Code..."
wget -O "$download_location" "$download_url"

# Install Visual Studio Code
echo "Installing Visual Studio Code..."
sudo dpkg -i "$download_location"
sudo apt-get install -f -y

# Cleanup
echo "Cleaning up..."
rm "$download_location"

echo "Installation completed."

# Install system components for powershell
sudo apt update && sudo apt install -y curl gnupg apt-transport-https

# Save the public repository GPG keys
curl https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --yes --dearmor --output /usr/share/keyrings/microsoft.gpg

# Register the Microsoft Product feed
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'

# Install PowerShell
sudo apt update && sudo apt install -y powershell

# Start PowerShell
# pwsh

echo "$USER"
sudo sh -c 'echo "deb https://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb https://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware
deb https://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb https://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware
" > /etc/apt/sources.list'

sudo apt update && apt list --upgradable && sudo apt upgrade -y
#sudo apt install nvidia-driver firmware-misc-nonfree -y

#sudo nvidia-settings

# Install video acceleration for HD Intel i965
sudo apt install -y i965-va-driver libva-drm2 libva-x11-2 vainfo

# Install samba and create user/group
read -r -p "Install samba and create user/group" -t 2 -n 1 -s && clear

sudo groupadd samba
sudo useradd -m tolga
sudo smbpasswd -a tolga
sudo usermod -aG samba tolga

read -r -p "Continuing..." -t 1 -n 1 -s && clear
clear

# Configure custom samba folder
read -r -p "Create and configure custom samba folder" -t 2 -n 1 -s && clear

sudo mkdir /home/Deb-12
sudo chgrp samba /home/Deb-12
sudo chmod 770 /home/Deb-12

read -r -p "Continuing..." -t 1 -n 1 -s && clear
clear

# Configure samba permissions and firewall
read -r -p "Configure samba permissions and firewall" -t 2 -n 1 -s && clear

read -r -p "\nContinuing..." -t 1 -n 1 -s && clear
clear

# Configure user shares
read -r -p "Create and configure user shares" -t 2 -n 1 -s && clear

sudo mkdir /var/lib/samba/usershares
sudo groupadd -r sambashare
sudo chown root:sambashare /var/lib/samba/usershares
sudo chmod 1770 /var/lib/samba/usershares
sudo gpasswd sambashare -a tolga
sudo usermod -aG sambashare tolga

read -r -p "Continuing..." -t 1 -n 1 -s && clear
clear

# Configure fstab
read -r -p "Configure fstab" -t 2 -n 1 -s && clear

# Backup the original /etc/fstab file
sudo cp /etc/fstab /etc/fstab.backup

# Define the mount entries
mount_entries=(
    "//192.168.0.20/LinuxData /mnt/linux-data cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s 0 0"
    "//192.168.0.20/LinuxData/HOME/PROFILES /mnt/home-profiles cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s 0 0"
    "//192.168.0.20/LinuxData/BUDGET-ARCHIVE/ /media/Budget-Archives cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s 0 0"
    "//192.168.0.20/WINDOWSDATA /mnt/windows-data cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s 0 0"
)

# Append the mount entries to /etc/fstab
for entry in "${mount_entries[@]}"; do
    echo "$entry" | sudo tee -a /etc/fstab >/dev/null
done

echo "Mount entries added to /etc/fstab."

sudo systemctl daemon-reload

read -r -p "Continuing..." -t 1 -n 1 -s && clear
clear

# Create mount points and set permissions
read -r -p "Create mount points and set permissions" -t 2 -n 1 -s && clear && echo ""

sudo mkdir -p /mnt/Budget-Archives
sudo mkdir -p /mnt/home-profiles
sudo mkdir -p /mnt/linux-data
sudo mkdir -p /mnt/smb
sudo mkdir -p /mnt/smb-budget
sudo mkdir -p /mnt/smb-rsync
sudo mkdir -p /mnt/windows-data
sudo chmod 777 /mnt/Budget-Archives
sudo chmod 777 /mnt/home-profiles
sudo chmod 777 /mnt/linux-data
sudo chmod 777 /mnt/smb
sudo chmod 777 /mnt/smb-budget
sudo chmod 777 /mnt/smb-rsync
sudo chmod 777 /mnt/windows-data

read -r -p "Continuing..." -t 1 -n 1 -s && clear
clear

# Mount the shares and start services
read -r -p "Mount the shares and start services" -t 2 -n 1 -s && clear && echo ""

sudo mount -a || {
    echo "Mount failed"
    exit 1
}
sudo systemctl enable smb nmb || {
    echo "Failed to enable services"
    exit 1
}
sudo systemctl restart smb.service nmb.service || {
    echo "Failed to restart services"
    exit 1
}
sudo systemctl daemon-reload

read -r -p "Continuing..." -t 1 -n 1 -s && clear
clear

# Test the fstab entries
read -r -p "Test the fstab entries" -t 2 -n 1 -s && clear

sudo ls /mnt/home-profiles || {
    echo "Failed to list Linux data"
    exit 1
}
sudo ls /mnt/linux-data || {
    echo "Failed to list Linux data"
    exit 1
}
sudo ls /mnt/smb || {
    echo "Failed to list SMB share"
    exit 1
}
sudo ls /mnt/windows-data || {
    echo "Failed to list Windows data"
    exit 1
}
sudo ls /mnt/Budget-Archives || {
    echo "Failed to list Windows data"
    exit 1
}
sudo ls /mnt/smb-budget || {
    echo "Failed to list Windows data"
    exit 1
}
sudo ls /mnt/smb-rsync || {
    echo "Failed to list Windows data"
    exit 1
}

read -r -p "Continuing..." -t 1 -n 1 -s && clear
clear

read -r -p "Add current user into sudoers group" -t 2 -n 1 -s && clear

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

read -r -p "Copy WALLPAPER to user home" -t 2 -n 1 -s && clear

folder_path="/home/$username/Pictures/CustomWallpapers"

if [ ! -d "$folder_path" ]; then
    echo "Creating folder 'CustomWallpapers'..."
    sudo mkdir -p "$folder_path"
    sudo chown -R $username:$username "$folder_path"
    sudo chmod -R 700 "$folder_path"
fi

echo "Copying WALLPAPER to $folder_path..."
sudo cp -r ./WALLPAPERS/* "$folder_path"
sudo chown -R $username:$username "$folder_path"
sudo chmod -R 700 "$folder_path"

echo "Continuing..."
sleep 1
clear

read -r -p "Copying samba files" -t 2 -n 1 -s && clear && echo ""

# Get the script's folder path
script_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the backup folder path
backup_folder="/etc/samba/backup"

# Create the backup folder if it doesn't exist
mkdir -p "$backup_folder"

# Define the original folder path
original_folder="/etc/samba/ORIGINAL"

# Create the original folder if it doesn't exist
mkdir -p "$original_folder"

# Enable extglob option
shopt -s extglob

# Define the backup folder path
backup_folder="/etc/samba/backup"

# Create the backup folder if it doesn't exist
mkdir -p "$backup_folder"

# Define the original folder path
original_folder="/etc/samba/ORIGINAL"

# Create the original folder if it doesn't exist
mkdir -p "$original_folder"

# Move contents of /etc/samba (excluding ORIGINAL folder) to original folder
mv /etc/samba/!(ORIGINAL) "$original_folder"

# Copy contents of /etc/samba to backup folder
cp -R "$original_folder"/* "$backup_folder"

# Specify the source folder path
script_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_folder="$script_folder/SAMBA"

# Check if the source folder exists
if [ -d "$source_folder" ]; then
    # Copy contents of script's samba folder to /etc/samba
    cp -R "$source_folder"/* /etc/samba
else
    echo "Source folder not found: $source_folder"
fi

# Refresh /etc/samba
systemctl restart smb.service

read -r -p "Continuing..." -t 1 -n 1 -s && clear

read -r -p "Copying script files" -t 2 -n 1 -s && clear && echo ""

# Specify the destination folder path
destination_folder="/opt/MYTOOLS"

# Create the destination folder if it doesn't exist
mkdir -p "$destination_folder"

# Specify the source folder path
source_folder="$script_folder/SCRIPTS"

# Check if the source folder exists
if [ -d "$source_folder" ]; then
    # Copy contents of the source folder to the destination folder
    cp -R "$source_folder"/* "$destination_folder"

    # Set permissions for the copied files
    chmod -R +rwx "$destination_folder"

    echo "Files copied successfully to $destination_folder."
else
    echo "Source folder not found: $source_folder"
fi

read -r -p "Complete..." -t 1 -n 1 -s

echo "Done. Time to defrag or fstrim."
sudo fstrim -v /
echo "Operation completed."

exit 0
