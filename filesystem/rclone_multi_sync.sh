#!/bin/bash

# Set the local directory to sync (modify this path as needed)
LOCAL_PATH="/path/to/local/dir"

# Get all rclone remote names
mapfile -t REMOTES < <(rclone listremotes | sed 's/://')

if [ ${#REMOTES[@]} -eq 0 ]; then
  echo "No rclone remotes detected. Please run 'rclone config' to set up your cloud remotes first."
  exit 1
fi

# Display the list of detected remotes
echo "Detected the following cloud remotes:"
for i in "${!REMOTES[@]}"; do
  echo "$((i+1)) - ${REMOTES[$i]}"
done

# Prompt user to select remotes (e.g., 1 2), default is all
read -p "Enter the numbers of the remotes to sync and check (space-separated, press Enter for all): " INPUT

# Use all remotes if no input
if [ -z "$INPUT" ]; then
  SELECTED=("${REMOTES[@]}")
else
  SELECTED=()
  for num in $INPUT; do
    index=$((num-1))
    if [ "$index" -ge 0 ] && [ "$index" -lt "${#REMOTES[@]}" ]; then
      SELECTED+=("${REMOTES[$index]}")
    else
      echo "Warning: Invalid number $num, skipping."
    fi
  done
fi

# Start sync and check for each selected remote
for remote in "${SELECTED[@]}"; do
  echo "--------------------------------------------"
  echo "Syncing: $remote"
  rclone sync "$LOCAL_PATH" "${remote}:" --progress

  echo "Checking: $remote"
  rclone check "$LOCAL_PATH" "${remote}:"

  echo "$remote sync and check completed."
done

echo "All operations completed."
