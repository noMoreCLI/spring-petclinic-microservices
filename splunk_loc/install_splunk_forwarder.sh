#!/bin/bash

# Exit on any error
set -e

# Check if script is run with sudo/root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo"
    exit 1
fi

# Create user and group if they don't exist
if ! getent group splunkfwd >/dev/null; then
    groupadd splunkfwd
fi

if ! id -u splunkfwd >/dev/null 2>&1; then
    useradd -m -g splunkfwd splunkfwd
fi

# Set Splunk home directory
export SPLUNK_HOME="/opt/splunkforwarder"

# Create Splunk home directory if it doesn't exist
if [ ! -d "$SPLUNK_HOME" ]; then
    mkdir -p "$SPLUNK_HOME"
fi

# Check if .deb package exists in current directory
if ! ls splunkforwarder*.deb 1> /dev/null 2>&1; then
    echo "Error: Splunk Forwarder .deb package not found in current directory"
    exit 1
fi

# Install the package
dpkg -i splunkforwarder*.deb

# Set proper ownership
chown -R splunkfwd:splunkfwd "$SPLUNK_HOME"

# Start Splunk
"$SPLUNK_HOME/bin/splunk" start --accept-license --no-prompt

# Configure forwarding to splunk.com:9997
"$SPLUNK_HOME/bin/splunk" add forward-server splunk.com:9997 -auth admin:changeme

# Configure monitoring for visits-service
"$SPLUNK_HOME/bin/splunk" add monitor path/to/visits-service -auth admin:changeme

# Restart Splunk to apply changes
"$SPLUNK_HOME/bin/splunk" restart

echo "Splunk Universal Forwarder installation and configuration completed successfully"