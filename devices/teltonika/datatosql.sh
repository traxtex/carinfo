#!/bin/bash

# Define the JSON file, output SQL file, and image directory
JSON_FILE="teltonika.json"
OUTPUT_SQL_FILE="teltonika.sql"
IMAGE_DIR="../../imgs/devices/teltonika"
BASE_URL="https://gh.traxtex.com/imgs/devices/teltonika"

# Create the image directory if it doesn't exist
mkdir -p $IMAGE_DIR

# Create or overwrite the output SQL file
echo "" > $OUTPUT_SQL_FILE

# Function to log messages
log() {
    echo "[INFO] $1"
}

log "Starting script..."

# Read and parse the JSON file, then generate SQL INSERT statements and download images
jq -c '.[]' $JSON_FILE | while read -r record; do
    device_name=$(echo $record | jq -r '.["device-name"]')
    manufacturer="Teltonika"  # Assuming the manufacturer is always "Teltonika"
    model=$(echo $record | jq -r '.["teltonika-devices"]')
    description=$(echo $record | jq -r '.["device-desc"]' | sed "s/'/''/g")
    documentation_link=$(echo $record | jq -r '.["device-external-link"]')
    photo_link=$(echo $record | jq -r '.["device-img-src"]')
    protocol="Unknown"  # Protocol not available in the JSON, set to "Unknown" or modify as needed
    tags=""  # No tags in the JSON, set to empty
    device_type="0"  # Device type is empty in JSON, set to 0 as default

    # Download the image with a timeout and retries
    file_name=$(basename $photo_link)
    log "Downloading image: $photo_link"

    retries=5
    success=false
    for ((i=1; i<=retries; i++)); do
        log "Attempt $i of $retries"
        wget -nv --show-progress --timeout=30 --tries=3 $photo_link -O $IMAGE_DIR/$file_name 2>&1 | tee -a wget.log
        if [ $? -eq 0 ]; then
            log "Downloaded image successfully: $file_name"
            success=true
            break
        else
            log "Failed to download image: $file_name"
        fi
    done

    if [ "$success" = false ]; then
        log "Giving up on downloading image: $file_name after $retries attempts"
        continue
    fi

    # Update photo link to the new URL
    new_photo_link="$BASE_URL/$file_name"

    # Generate SQL INSERT statement
    sql_statement="INSERT INTO device_models (name, manufacturer, model, description, documentation_link, photo_link, protocol, tags, device_type) VALUES ('$device_name', '$manufacturer', '$model', '$description', '$documentation_link', '$new_photo_link', '$protocol', '$tags', '$device_type');"
    echo $sql_statement >> $OUTPUT_SQL_FILE
    log "Generated SQL statement for: $device_name"
done

log "Script completed. Output written to $OUTPUT_SQL_FILE"
