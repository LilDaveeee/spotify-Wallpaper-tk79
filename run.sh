#!/bin/bash

BASE_DIR="$(dirname "$(realpath "$0")")"
IMAGE_DIR="$BASE_DIR/images"
BACKGROUND_DIR="$BASE_DIR/backgrounds"
FETCH_ART_SCRIPT="$BASE_DIR/fetchArt.sh"
GENERATE_IMG_SCRIPT="$BASE_DIR/generateImg.sh"
TIMESTAMP_FILE="$IMAGE_DIR/last_timestamp.txt"
ALBUM_ART_IMAGE="$IMAGE_DIR/albumArt.jpg"
RES_WIDTH=2560
RES_HEIGHT=1440
mkdir -p "$IMAGE_DIR"
mkdir -p "$BACKGROUND_DIR"
get_last_modified_time() {
    if [ -f "$ALBUM_ART_IMAGE" ]; then
        stat --format=%Y "$ALBUM_ART_IMAGE" 2>/dev/null
    else
        echo 0
    fi
}
if [ ! -f "$TIMESTAMP_FILE" ]; then
    touch "$TIMESTAMP_FILE"
fi
previous_timestamp=$(get_last_modified_time)
while true; do
    "$FETCH_ART_SCRIPT" "$IMAGE_DIR"
    current_timestamp=$(get_last_modified_time)
    if [ "$current_timestamp" -ne "$previous_timestamp" ]; then
        echo "Album art has changed, generating new wallpaper..."
        "$GENERATE_IMG_SCRIPT"
        BACKGROUND_IMAGE="$BACKGROUND_DIR/background.jpg"
        ABSOLUTE_BACKGROUND_PATH=$(realpath "$BACKGROUND_IMAGE")
        if [ -f "$ABSOLUTE_BACKGROUND_PATH" ]; then
            echo "Background image found: $ABSOLUTE_BACKGROUND_PATH"
            gsettings set org.gnome.desktop.background picture-options 'centered'
            URI="file://$ABSOLUTE_BACKGROUND_PATH"
            gsettings set org.gnome.desktop.background picture-uri-dark "$URI"
            # for light mode remove dark from picture-uri
            echo "New wallpaper set successfully using gsettings."
            previous_timestamp="$current_timestamp"
        else
            echo "Error: shit dont exist"
            exit 1
        fi
    else
        echo "No Change. Retrying in 2"
    fi
    sleep 2
done

