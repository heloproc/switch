#!/bin/bash

# Path to the directory containing your wallpapers
WALLPAPER_DIR=/path/to/wallpapers/directory

# List of wallpaper files (directly in the script)
WALLPAPERS=(
  "$WALLPAPER_DIR/file-1.jpeg"
  "$WALLPAPER_DIR/file-2.jpg"
)

# Get the current desktop environment (Gnome, KDE, etc.)
DESKTOP_SESSION=$(echo "$XDG_CURRENT_DESKTOP")

# File to store the current wallpaper index
INDEX_FILE="$HOME/.wallpaper_index"

# Function to change the wallpaper based on the desktop environment
change_wallpaper() {
  local wallpaper="$1"

  case "$DESKTOP_SESSION" in
    "ubuntu:GNOME" | "GNOME")
      # Set wallpaper for Gnome (and Ubuntu's default Gnome)
      gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper"
      gsettings set org.gnome.desktop.background picture-uri-dark "file://$wallpaper"
      ;;
    "KDE")
      # Set wallpaper for KDE Plasma
      dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript 'string:
        var Desktops = desktops();
        for (i=0;i<Desktops.length;i++) {
            d = Desktops[i];
            d.wallpaperPlugin = "org.kde.image";
            d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
            d.writeConfig("Image", "file://'$wallpaper'");
        }'
      ;;
    "XFCE")
      # Set wallpaper for XFCE
      xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/workspace0/last-image --set "$wallpaper"
      ;;
    *)
      echo "Error: Unsupported desktop environment: $DESKTOP_SESSION"
      exit 1
      ;;
  esac
}

# Check if the wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "Error: Wallpaper directory not found: $WALLPAPER_DIR"
  exit 1
fi

# Get the total number of wallpapers
NUM_WALLPAPERS=${#WALLPAPERS[@]}

# Read the current wallpaper index from the index file
if [ -f "$INDEX_FILE" ]; then
  wallpaper_index=$(cat "$INDEX_FILE")
else
  wallpaper_index=0
fi

# Get the current wallpaper path
current_wallpaper="${WALLPAPERS[$wallpaper_index]}"

# Check if the wallpaper file exists
if [ -f "$current_wallpaper" ]; then
  change_wallpaper "$current_wallpaper"
  echo "Wallpaper changed to: $current_wallpaper"
else
  echo "Error: Wallpaper file not found: $current_wallpaper"
fi

# Increment the wallpaper index (and loop back to 0 if we reach the end)
wallpaper_index=$(( (wallpaper_index + 1) % NUM_WALLPAPERS ))

# Save the updated wallpaper index to the index file
echo "$wallpaper_index" > "$INDEX_FILE"

echo "Finished changing wallpaper."
