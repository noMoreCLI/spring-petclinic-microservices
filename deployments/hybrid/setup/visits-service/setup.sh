#!/bin/bash
CONFIG_FILE="/etc/environment"  # Change to ~/.zshrc or ~/.profile for other shells

# Append STUDENT_ID to the shell configuration file
persist_variable() {
    if ! grep -q "export STUDENT_ID=" "$CONFIG_FILE"; then
        echo "export STUDENT_ID=${STUDENT_ID}" >> "$CONFIG_FILE"
        echo "STUDENT ID has been saved to $CONFIG_FILE."
    else
        # Update the existing STUDENT_ID entry
        sed -i "s/^export STUDENT_ID=.*/export STUDENT_ID=${STUDENT_ID}/" "$CONFIG_FILE"
        echo "STUDENT ID has been updated in $CONFIG_FILE."
    fi
}

# Function to validate if the input is a valid number
is_valid_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Function to get STUDENT ID
get_student_id() {
    while true; do
        read -p "Enter a valid Student ID (must be a number): " STUDENT_ID
        if is_valid_number "${STUDENT_ID}"; then
            export STUDENT_ID
            echo "STUDENT ID set to: ${STUDENT_ID}"
            break
        else
            echo "Invalid input. Please enter a valid number."
        fi
    done
}

# Main logic
# Parse command-line arguments
unset STUDENT_ID
for arg in "$@"; do
    case $arg in
        --studentID=*)
            STUDENT_ID="${arg#*=}"
            if is_valid_number "${STUDENT_ID}"; then
                export STUDENT_ID
                echo "STUDENT ID set to: ${STUDENT_ID} (via command-line argument)"
            else
                echo "Invalid STUDENT ID provided as an argument. It must be a number."
                exit 1
            fi
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Usage: $0 [--studentID=<number>]"
            exit 1
            ;;
    esac
done

if [ -z "${STUDENT_ID}" ]; then
    get_student_id
fi

persist_variable

#### Node Setup

USER_NAME="${USER_NAME:-cisco}"
USER_PASSWORD="${USER_PASSWORD:-C1sco12345}"
ROOT_PASSWORD="${ROOT_PASSWORD:-C1sco12345}"
echo "Setting Hostname"
hostnamectl set-hostname visits-service-${STUDENT_ID}

echo "Setting Password for root"
echo "root:${ROOT_PASSWORD}" | chpasswd

echo "Creating Cisco User"
useradd -m -s /bin/bash ${USER_NAME}
echo "Setting Password for ${USER_NAME}"
echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd
echo "Adding ${USER_NAME} to sudo group"
usermod -aG sudo ${USER_NAME}

cp /etc/hosts /etc/hosts.bak
rm /etc/hosts
echo "Adding hosts entries" >> /etc/hosts
echo "::1     ip6-localhost ip6-loopback" >> /etc/hosts
echo " fe00::0 ip6-localnet" >> /etc/hosts
echo "ff00::0 ip6-mcastprefix" >> /etc/hosts
echo "ff02::1 ip6-allnodes" >> /etc/hosts
echo "ff02::2 ip6-allrouters" >> /etc/hosts
echo "198.18.134.22    ansible-${STUDENT_ID}" >> /etc/hosts
echo "198.18.134.25    petclinic-db petclinic-db-${STUDENT_ID}" >> /etc/hosts
echo "198.18.134.24    visits-service-${STUDENT_ID}" >> /etc/hosts
echo "198.18.134.23    config-server discovery-server customers-service vets-service admin-service genai-service api-gateway" >> /etc/hosts

echo "Updateing System"
apt update && apt upgrade -y
apt install -y retry snapd git wget curl mysql-client ca-certificates openjdk-17-jdk

###### Updateing from github repo

echo "Cloning CL2025 US Lab Repository for user: ${USER_NAME}"

DIR="/home/$USER_NAME/spring-petclinic-microservices"

if [ -d "$DIR" ]; then
    su - ${USER_NAME} -c "cd $DIR && git pull"
else
    su - ${USER_NAME} -c "git clone --branch cl25us --depth 1 https://github.com/noMoreCLI/spring-petclinic-microservices.git"
fi
