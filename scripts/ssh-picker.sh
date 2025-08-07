#!/usr/bin/env bash

CONFIG_DIR="$(dirname "$(tmux show-env -g TMUX_PLUGIN_MANAGER_PATH | cut -f2 -d=)")"
CONFIG_FILE="$CONFIG_DIR/profiles.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Profile file not found in $CONFIG_DIR"
  exit 1
fi

# Check dependencies
command -v fzf >/dev/null || {
  echo "fzf required"
  exit 1
}
command -v yq >/dev/null || {
  echo "yq required"
  exit 1
}

# Parse config and present fzf
selection=$(
  yq -o=json '.[]' $CONFIG_FILE |
    jq -rc '["\(.label) [\(.user)@\(.host)]","\(.label) [\(.user)@\(.host)]:::\(.window):::\(.user):::\(.host):::\(.key // "-")"] | @tsv' |
    fzf --style full \
      --prompt "" \
      --with-nth=1 \
      --delimiter "\t" \
      --border-label="[ Server Selection ]" \
      --border=rounded \
      --highlight-line \
      --cycle \
      --preview="echo '{}' | cut -f2 | awk -F ':::' '{ printf \"Window: %s\nHost: %s\nUser: %s\nKey: %s\n\", \$2, \$4, \$3, \$5 }'" \
      --preview-window=up \
      --preview-label=" Profile " \
      --list-label=" List " \
      --pointer=">"
)

# Bail
[ -z "$selection" ] && exit 0

# Split values
raw_line=$(echo "$selection" | cut -f2)
window=$(echo "$raw_line" | head -n 1 | awk -F ':::' '{print $2}')
user=$(echo "$raw_line" | head -n 1 | awk -F ':::' '{print $3}')
host=$(echo "$raw_line" | head -n 1 | awk -F ':::' '{print $4}')
key=$(echo "$raw_line" | head -n 1 | awk -F ':::' '{print $5}')

# Build command
if [ -n "$key" ]; then
  cmd="ssh -tt -i $key $user@$host"
else
  cmd="ssh -tt $user@$host"
fi

# Run in new tmux window using bash wrapper (Fish-safe)
tmux new-window -n "$window" "bash -c '$cmd || read -p \"SSH failed. Press Enter...\"'"
