#!/bin/bash

# Exit on any error
set -e

#-----------------------------------------------------------------------
# CONFIGURABLE SPLUNK VARIABLES
# Please review and update these variables as per your environment
#-----------------------------------------------------------------------

# Splunk Cloud Admin Credentials
# IMPORTANT: Storing passwords directly in scripts is a security risk.
# Consider using environment variables or a secrets management tool for production.
SPLUNK_ADMIN_USERNAME="admin"
SPLUNK_ADMIN_PASSWORD='41M&CzoU^7g&it&tG23sHaf071y9%4sWYr^h&l%5_#yRk^_86pnd&7_81cP%q&Nr' # Quoted to handle special characters

# Splunk Cloud Forwarding Destination (Receiver)
# This is derived from your Stack URL. Data will be sent here.
SPLUNK_FORWARD_SERVER_HOSTNAME="scv-shw-12cdc3a9c00cff.stg.splunkcloud.com"
SPLUNK_FORWARD_SERVER_PORT="9997" # Default Splunk Cloud receiving port

# Path to the data you want to monitor on this machine
# !!! CHANGE THIS TO THE ACTUAL PATH of the log file or directory for "visits-service" !!!
PATH_TO_MONITOR="/var/log/visits-service/access.log" # Example: /var/log/myapp/app.log or /opt/my_app/logs/

# Splunk User and Group
SPLUNK_USER="splunkfwd"
SPLUNK_GROUP="splunkfwd"

# Set Splunk home directory
export SPLUNK_HOME="/opt/splunkforwarder"
#-----------------------------------------------------------------------

echo "Starting Splunk Universal Forwarder installation and configuration..."

# Check if script is run with sudo/root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo"
    exit 1
fi

# Create user and group if they don't exist
echo "Ensuring Splunk user ($SPLUNK_USER) and group ($SPLUNK_GROUP) exist..."
if ! getent group "$SPLUNK_GROUP" >/dev/null; then
    echo "Group $SPLUNK_GROUP does not exist. Creating..."
    groupadd "$SPLUNK_GROUP"
    echo "Group $SPLUNK_GROUP created."
else
    echo "Group $SPLUNK_GROUP already exists."
fi

if ! id -u "$SPLUNK_USER" >/dev/null 2>&1; then
    echo "User $SPLUNK_USER does not exist. Creating..."
    useradd -m -g "$SPLUNK_GROUP" "$SPLUNK_USER"
    echo "User $SPLUNK_USER created."
else
    echo "User $SPLUNK_USER already exists."
fi

# Create Splunk home directory if it doesn't exist
echo "Ensuring Splunk home directory ($SPLUNK_HOME) exists..."
if [ ! -d "$SPLUNK_HOME" ]; then
    echo "Directory $SPLUNK_HOME does not exist. Creating..."
    mkdir -p "$SPLUNK_HOME"
    echo "Directory $SPLUNK_HOME created."
else
    echo "Directory $SPLUNK_HOME already exists."
fi

# Check if .deb package exists in current directory
echo "Checking for Splunk Forwarder .deb package..."
if ! ls splunkforwarder*.deb 1> /dev/null 2>&1; then
    echo "Error: Splunk Forwarder .deb package not found in current directory."
    echo "Please download the Splunk Universal Forwarder .deb package and place it in the same directory as this script."
    exit 1
fi
echo "Splunk Forwarder .deb package found."

# Install the package
echo "Installing Splunk Forwarder package..."
dpkg -i splunkforwarder*.deb
echo "Splunk Forwarder package installed."

# Set proper ownership
echo "Setting ownership of $SPLUNK_HOME to $SPLUNK_USER:$SPLUNK_GROUP..."
chown -R "$SPLUNK_USER":"$SPLUNK_GROUP" "$SPLUNK_HOME"
echo "Ownership set."

# Start Splunk (as the splunkfwd user)
echo "Starting Splunk Universal Forwarder..."
sudo -u "$SPLUNK_USER" "$SPLUNK_HOME/bin/splunk" start --accept-license --no-prompt --answer-yes
echo "Splunk Universal Forwarder started."

# Configure forwarding to Splunk Cloud
FORWARD_SERVER_TARGET="${SPLUNK_FORWARD_SERVER_HOSTNAME}:${SPLUNK_FORWARD_SERVER_PORT}"
echo "Configuring forwarding to $FORWARD_SERVER_TARGET..."
sudo -u "$SPLUNK_USER" "$SPLUNK_HOME/bin/splunk" add forward-server "$FORWARD_SERVER_TARGET" -auth "${SPLUNK_ADMIN_USERNAME}:${SPLUNK_ADMIN_PASSWORD}"
echo "Forwarding configured."

# Configure monitoring for the specified path
# Ensure the PATH_TO_MONITOR variable is set correctly above.
if [ -z "$PATH_TO_MONITOR" ]; then
    echo "Warning: PATH_TO_MONITOR is not set. Skipping 'add monitor' command."
    echo "Please set PATH_TO_MONITOR at the beginning of the script to the file or directory you wish to monitor."
else
    echo "Configuring monitoring for $PATH_TO_MONITOR..."
    # You might want to specify a sourcetype or index here as well, e.g., -sourcetype myapp_access -index myindex
    sudo -u "$SPLUNK_USER" "$SPLUNK_HOME/bin/splunk" add monitor "$PATH_TO_MONITOR" -auth "${SPLUNK_ADMIN_USERNAME}:${SPLUNK_ADMIN_PASSWORD}"
    echo "Monitoring for $PATH_TO_MONITOR configured."
fi

# Restart Splunk to apply changes (as the splunkfwd user)
echo "Restarting Splunk Universal Forwarder to apply changes..."
sudo -u "$SPLUNK_USER" "$SPLUNK_HOME/bin/splunk" restart
echo "Splunk Universal Forwarder restarted."

echo ""
echo "Splunk Universal Forwarder installation and configuration completed successfully."
echo "Forwarding to: $FORWARD_SERVER_TARGET"
if [ -n "$PATH_TO_MONITOR" ]; then
    echo "Monitoring path: $PATH_TO_MONITOR"
fi
echo "Make sure the path '$PATH_TO_MONITOR' exists and has readable permissions for the '$SPLUNK_USER' user."
echo "Check your Splunk Cloud instance ($SPLUNK_FORWARD_SERVER_HOSTNAME) for incoming data."

