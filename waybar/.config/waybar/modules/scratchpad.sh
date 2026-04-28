#!/bin/bash

apps=$(hyprctl clients -j | jq -r '
  .[]
  | select(.workspace.name == "special:scratchpad")
  | .class
')

if [ -z "$apps" ]; then
  echo ""
  exit 0
fi

icons=""

for app in $apps; do
  case "$app" in
    kitty|Alacritty|foot|ghostty)
      icons="$icons "
      ;;
    firefox|Firefox)
      icons="$icons "
      ;;
    chromium|Chromium|google-chrome|Google-chrome)
      icons="$icons "
      ;;
    code|Code)
      icons="$icons "
      ;;
    spotify|Spotify)
      icons="$icons "
      ;;
    discord|Discord)
      icons="$icons "
      ;;
    thunar|Thunar|nautilus|Nautilus)
      icons="$icons "
      ;;
    mutui|Mutui)
      icons="$icons "
      ;;
    *)
      icons="$icons "
      ;;
  esac
done

titles=$(hyprctl clients -j | jq -r '
  .[]
  | select(.workspace.name == "special:scratchpad")
  | .title
')

echo "{\"text\": \"$icons\", \"tooltip\": \"$titles\"}"
