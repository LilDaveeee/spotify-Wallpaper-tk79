#!/bin/bash
FETCH_ART_SCRIPT="./fetchArt.sh"
RES_WIDTH=2560
RES_HEIGHT=1440
BASE_DIR="$(dirname "$(realpath "$0")")"
IMAGE_DIR="$BASE_DIR/images"
BACKGROUND_DIR="$BASE_DIR/backgrounds"
mkdir -p "$IMAGE_DIR"
mkdir -p "$BACKGROUND_DIR"
"$FETCH_ART_SCRIPT" "$IMAGE_DIR"

album_image="$IMAGE_DIR/albumArt.jpg"
if [ ! -f "$album_image" ]; then
    echo "No album image found."
    exit 1
fi
background_image="$BACKGROUND_DIR/background.jpg"
if ! file "$album_image" | grep -qE 'image|bitmap'; then
    echo "Downloaded file is not a valid image. Exiting."
    exit 1
fi
blurred_image="$BACKGROUND_DIR/blurred_album.jpg"
magick "$album_image" -resize "${RES_WIDTH}x${RES_HEIGHT}^" -gravity center -crop "${RES_WIDTH}x${RES_HEIGHT}+0+0" +repage -blur 0x10 "$blurred_image"
magick "$blurred_image" "$album_image" -geometry +$(( (RES_WIDTH - 600) / 2 ))+$(( (RES_HEIGHT - 600) / 2 )) -composite "$background_image"
echo "New wallpaper set with album cover in the center."

