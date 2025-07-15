
#!/usr/bin/env bash

BASE_DIR="$(dirname "$(realpath "$0")")"
IMAGE_DIR="$BASE_DIR/images"
BACKGROUND_DIR="$BASE_DIR/backgrounds"
FETCH_ART_SCRIPT="$BASE_DIR/fetchArt.sh"
GENERATE_IMG_SCRIPT="$BASE_DIR/generateImg.sh"
TIMESTAMP_FILE="$IMAGE_DIR/last_timestamp.txt"
ALBUM_ART_IMAGE="$IMAGE_DIR/albumArt.jpg"
RES_WIDTH=2560
RES_HEIGHT=1440

mkdir -p "$IMAGE_DIR" "$BACKGROUND_DIR"
[ -f "$TIMESTAMP_FILE" ] || touch "$TIMESTAMP_FILE"

get_last_modified_time() {
  if [ -f "$ALBUM_ART_IMAGE" ]; then
    stat --format=%Y "$ALBUM_ART_IMAGE" 2>/dev/null
  else
    echo 0
  fi
}

previous_timestamp=$(get_last_modified_time)

for script in "$FETCH_ART_SCRIPT" "$GENERATE_IMG_SCRIPT"; do
  [ -x "$script" ] || chmod +x "$script"
done

if command -v swww-daemon &>/dev/null; then
  if ! pgrep -x swww-daemon &>/dev/null; then
    swww-daemon & sleep 1
  fi
fi

while true; do
  "$FETCH_ART_SCRIPT" "$IMAGE_DIR"

  current_timestamp=$(get_last_modified_time)
  if [ "$current_timestamp" -ne "$previous_timestamp" ]; then
    echo "Album art changed – regenerating wallpaper…"
    "$GENERATE_IMG_SCRIPT"

    BACKGROUND_IMAGE="$BACKGROUND_DIR/background.jpg"
    ABS_PATH="$(realpath "$BACKGROUND_IMAGE")"
    if [ -f "$ABS_PATH" ]; then
      echo "Applying new wallpaper: $ABS_PATH"
      swww img "$ABS_PATH"
      echo "Wallpaper updated successfully."
      previous_timestamp="$current_timestamp"
    else
      echo "Error: generated background missing at $ABS_PATH"
      exit 1
    fi

  else
    echo "No change detected. Retrying in 2s…"
  fi

  sleep 2
done
