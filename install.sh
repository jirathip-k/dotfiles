#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Enable the Copr repository for Hyprland
dnf copr enable solopasha/hyprland -y

# Update the system
dnf update -y

# Install Hyprland and other necessary packages
dnf install hyprland sddm qt5-qtquickcontrols2 pipewire wl-clipboard -y

# Enable services
#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Enable the Copr repository for Hyprland
dnf copr enable solopasha/hyprland -y

# Update the system
dnf update -y

# Install Hyprland and other necessary packages
dnf install hyprland sddm qt5-qtquickcontrols2 pipewire wl-clipboard -y

# Enable services
systemctl enable sddm pipewire
