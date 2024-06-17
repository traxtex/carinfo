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

# Function to map device type to enum value
map_device_type() {
    case "$1" in
        "Basic Trackers") echo 1 ;;
        "Fast & Easy Trackers") echo 2 ;;
        "Advanced Trackers") echo 3 ;;
        "Autonomous Trackers") echo 4 ;;
        "Sensors") echo 5 ;;
        "OBD Trackers") echo 6 ;;
        "CAN Trackers & Adapters") echo 7 ;;
        "Professional Trackers") echo 8 ;;
        "Video Solutions") echo 9 ;;
        "E-Mobility Trackers") echo 10 ;;
        *) echo 0 ;;  # DEVICE_TYPE_OTHER as default
    esac
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
    protocol="Teltonika"  # Set protocol to "Teltonika"
    tags="{}"  # Set tags to empty array '{}'
    device_type_str=$(echo $record | jq -r '.["device-type"]')
    device_type=$(map_device_type "$device_type_str")

    # Check if the image already exists
    file_name=$(basename $photo_link)
    if [ -f $IMAGE_DIR/$file_name ]; then
        log "Image already exists, skipping download: $file_name"
    else
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
    fi

    # Update photo link to the new URL
    new_photo_link="$BASE_URL/$file_name"

    # Generate SQL INSERT statement
    sql_statement="INSERT INTO device_models (name, manufacturer, model, description, documentation_link, photo_link, protocol, tags, device_type) VALUES ('$device_name', '$manufacturer', '$model', '$description', '$documentation_link', '$new_photo_link', '$protocol', '$tags', $device_type);"
    echo $sql_statement >> $OUTPUT_SQL_FILE
    log "Generated SQL statement for: $device_name"
done

log "Script completed. Output written to $OUTPUT_SQL_FILE"
