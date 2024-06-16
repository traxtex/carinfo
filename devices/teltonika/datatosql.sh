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
    name=$(echo $record | jq -r '.["model-name"]')
    manufacturer=$(echo $record | jq -r '.["device-model-manufacturer"]')
    model=$(echo $record | jq -r '.["device-models-links"]')
    description=$(echo $record | jq -r '.["device-model-desc"]' | sed "s/'/''/g")
    documentation_link=$(echo $record | jq -r '.["device-models-links-href"]')
    photo_link=$(echo $record | jq -r '.["device-model-img-src"]')
    protocol=$(echo $record | jq -r '.["device-model-protocol"]')
    tags=$(echo $record | jq -r '.["device-models-tags"]' | sed 's/ /", "/g')
    tags="{\"$tags\"}"

    # Download the image
    file_name=$(basename $photo_link)
    log "Downloading image: $photo_link"
    wget -nv --show-progress $photo_link -O $IMAGE_DIR/$file_name 2>&1 | tee -a wget.log

    # Check if the download was successful
    if [ $? -eq 0 ]; then
        log "Downloaded image successfully: $file_name"
    else
        log "Failed to download image: $file_name"
    fi

    # Update photo link to the new URL
    new_photo_link="$BASE_URL/$file_name"

    # Generate SQL INSERT statement
    sql_statement="INSERT INTO device_models (name, manufacturer, model, description, documentation_link, photo_link, protocol, tags) VALUES ('$name', '$manufacturer', '$model', '$description', '$documentation_link', '$new_photo_link', '$protocol', '$tags');"
    echo $sql_statement >> $OUTPUT_SQL_FILE
    log "Generated SQL statement for: $name"
done

log "Script completed. Output written to $OUTPUT_SQL_FILE"
