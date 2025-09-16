#!/usr/bin/env bash

set -eo pipefail

get_keyvalue() {
    local key="$1"
    local file="$2"
    # Extract the value then trim leading and trailing whitespace
    sed -n -E "s/^[[:space:]]*${key}:[[:space:]]*[\"']?([^\"'#]+)[\"']?.*$/\1/p" "$file" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

echo "Initializing FDO Manufacturing Server"

# Source directory for config file
CONFIG_SOURCE_DIR="/etc/fdo/fdo-manufacturing"

# Manufacturing server config file
CONFIG_FILE="fdo-manufacturing-config.yaml"

# Check if fdo-manufacturing-config file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: FDO manufacturing server config file not found at $CONFIG_SOURC_DIR/$CONFIG_FILE"
  exit 1
fi

# ENV file to be used by fdo manufacturing server
ENV_OUTPUT="/etc/fdo/fdo-manufacturing/env"

# Environment template file to use
ENV_TEMPLATE="/usr/bin/fdo-manufacturing-env.template"

# Get value for HOST_IP from config file
HOST_IP=$(get_keyvalue "host_ip" "$CONFIG_FILE")
# verify HOST_IP is specified in config
if [ -z "$HOST_IP" ]; then
    echo "Error: host_ip is missing in config file"
    exit 1
fi

# Get value for port from config file
PORT=$(get_keyvalue "port" "$CONFIG_FILE")
#verify PORT is specified in config
if [ -z "$PORT" ]; then
    echo "Error: port is missing in config file"
    exit 1
fi

# Get value for manufacturing server private key path from config file
MANUFACTURING_KEY=$(get_keyvalue "manufacturing_key" "$CONFIG_FILE")
#verify manufacturing server private key path is specified in config file
if [ -z "$MANUFACTURING_KEY" ]; then
    echo "Error: manufacturing server private key is missing in config file"
    exit 1
fi

# Get Owner cert path from config file
OWNER_CA_CERT=$(get_keyvalue "owner_ca_cert", "$CONFIG_FILE")
#Verify owner ca cert is specified in config 
if [ -z "$OWNER_CA_CERT" ]; then
    echo "Error: Owner ca certificate is missing in config file"
    exit 1
fi

#Get device Cert and key path from config file
DEVICE_CA_KEY=$(get_keyvalue "device_ca_key" "$CONFIG_FILE")
DEVICE_CA_CERT=$(get_keyvalue "device_ca_cert" "$CONFIG_FILE")
# verify device ca cert and key is specified in config file
if [ -z "$DEVICE_CA_KEY" || -z "$DEVICE_CA_CERT" ]; then
    echo "Error: Device CA Cert and key are required"
    exit 1 
fi

#Get DB
DB=$(get_keyvalue "db" "$CONFIG_FILE")
#verify db name is set
if [ -z "$DB" ]; then
    echo "Error: DB file path is not set in config file"
    exit 1
fi

#create the env file using template
sed "s|{{HOST_IP}}|${HOST_IP}|g" "$ENV_TEMPLATE" > "$ENV_OUTPUT"
sed "s|{{PORT}}|${PORT}|g" "$ENV_TEMPLATE" > "$ENV_OUTPUT"
sed "s|{{MANUFACTURING_KEY}}|${MANUFACTURING_KEY}|g" "$ENV_TEMPLATE" > "$ENV_OUTPUT"
sed "s|{{OWNER_CA_CERT}}|${OWNER_CA_CERT}|g" "$ENV_TEMPLATE" > "$ENV_OUTPUT"
sed "s|{{DEVICE_CA_KEY}}|${DEVICE_CA_KEY}|g" "$ENV_TEMPLATE" > "$ENV_OUTPUT"
sed "s|{{DEVICE_CA_CERT}}|${DEVICE_CA_CERT}|g" "$ENV_TEMPLATE" > "$ENV_OUTPUT"
sed "s|{{DB}}|${DB}|g" "$ENV_TEMPLATE" > "$ENV_OUTPUT"

echo "Initialization of FDO Manufacturing server is complete"
