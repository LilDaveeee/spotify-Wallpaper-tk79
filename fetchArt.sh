#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No directory provided for saving images."
    exit 1
fi

IMAGE_DIR="$1"

mkdir -p "$IMAGE_DIR"
album_image_path="$IMAGE_DIR/albumArt.jpg"
album_art_url=$(playerctl -p spotify metadata | grep -oP 'mpris:artUrl\s+\K.*')
if [ -z "$album_art_url" ]; then
    echo "Error: No album art URL found."
    exit 1
fi
previous_url=$(cat "$IMAGE_DIR/previous_album_url" 2>/dev/null)
if [ "$album_art_url" == "$previous_url" ]; then
    echo "Album art is already the same, no update needed."
    exit 0
fi
echo "Downloading album art from: $album_art_url"
wget -q -O "$album_image_path" "$album_art_url"
if [ $? -ne 0 ]; then
    echo "Error: Failed to download album art from $album_art_url."
    exit 1
fi
echo "$album_art_url" > "$IMAGE_DIR/previous_album_url"
echo "Album art downloaded and saved as $album_image_path."

