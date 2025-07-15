#!/bin/bash
# --- Configuration ---
ROOT_DIR="/mnt/user/Movies"
RECURSIVE="no"
INCLUDE_HIDDEN="no"


# Enter a path to an existing directory where you want the report saved.
# Example: REPORT_SAVE_PATH="/mnt/user/temp/"
# If left blank or the path is invalid, no report will be saved.
REPORT_SAVE_PATH="/mnt/user/temp"

MEDIA_EXTENSIONS=(mp4 mkv avi mov wmv flv webm)

# HTML colours
BLUE_OPEN="<span style=\"color:blue\">"
BLUE_CLOSE="</span>"
RED_OPEN="<span style=\"color:red\">"
RED_CLOSE="</span>"


SAVE_REPORT_ENABLED=0
FINAL_REPORT_FILE=""

# Processes a single directory with duplicates

process_directory_with_duplicates() {
  local dir="$1"
  shift
  local -a files=("$@")

  # --- 1. Print to screen in real-time ---
  echo -e "${BLUE_OPEN}${dir}/${BLUE_CLOSE}"
  for file in "${files[@]}"; do
    local size_bytes
    local size_gb
    size_bytes=$(stat -c %s "$file")
    size_gb=$(awk -v b="$size_bytes" 'BEGIN {printf "%.2f GB", b/1024/1024/1024}')
    echo -e "  $file  (${RED_OPEN}${size_gb}${RED_CLOSE})"
  done
  echo 

  # --- 2. Conditionally write to the report file ---
  if [[ "$SAVE_REPORT_ENABLED" -eq 1 ]]; then
    echo "${dir}/" >> "$FINAL_REPORT_FILE"
    for file in "${files[@]}"; do
      local size_bytes
      local size_gb
      size_bytes=$(stat -c %s "$file")
      size_gb=$(awk -v b="$size_bytes" 'BEGIN {printf "%.2f GB", b/1024/1024/1024}')
      echo "  $file  ($size_gb)" >> "$FINAL_REPORT_FILE"
    done
    echo "" >> "$FINAL_REPORT_FILE"
  fi
}

# --- Main  ---

main() {
  # --- 1. Validate the user-defined report path ---
  if [[ -n "$REPORT_SAVE_PATH" && -d "$REPORT_SAVE_PATH" ]]; then
    SAVE_REPORT_ENABLED=1
    FINAL_REPORT_FILE="$REPORT_SAVE_PATH/duplicate_media_report.txt"
    # Clear any old report file at the destination first
    : > "$FINAL_REPORT_FILE"
    echo "Report will be saved to: $FINAL_REPORT_FILE"
  else
    echo "<b>Warning:</b> REPORT_SAVE_PATH is not set or is not a valid directory."
    echo "A report will NOT be saved. Continuing in 3 seconds..."
    sleep 3
  fi
  echo "---"

  # --- 2. Find all media files ---
  local -a name_patterns=()
  for ext in "${MEDIA_EXTENSIONS[@]}"; do
    name_patterns+=(-o -iname "*.${ext}")
  done
  
  local max_depth_arg=""
  if [[ "$RECURSIVE" != "yes" ]]; then
    max_depth_arg="-maxdepth 2"
  fi
  
  declare -A files_by_dir
  local file
  while IFS= read -r -d '' file; do
    local dir
    dir=$(dirname "$file")
    files_by_dir["$dir"]+="${file}"$'\n'
  done < <(find "$ROOT_DIR" -mindepth 1 ${max_depth_arg} -type f ! -xtype l \( "${name_patterns[@]:1}" \) -print0)

  # --- 3. Process results and print to screen ---
  local duplicates_found=0
  local duplicates_found_count=0
  for dir in "${!files_by_dir[@]}"; do
    if [[ "$INCLUDE_HIDDEN" != "yes" && "$(basename "$dir")" == .* ]]; then
      continue
    fi
    
    local -a files=()
    mapfile -t files < <(printf '%s' "${files_by_dir[$dir]}")

    if (( ${#files[@]} > 1 )); then
      duplicates_found=1
      ((duplicates_found_count++))
      
   
      process_directory_with_duplicates "$dir" "${files[@]}"
    fi
  done

  # --- 4. Print final  message ---
  echo "---"
  echo "Scan Complete."
  if [[ "$duplicates_found" -eq 0 ]]; then
      echo "No folders with multiple media files were found."
  else
    echo "Found <b>$duplicates_found_count</b> movies with multiple media files."
    if [[ "$SAVE_REPORT_ENABLED" -eq 1 ]]; then
      echo "A report has been saved to: <b>$FINAL_REPORT_FILE</b>"
    else
      echo "No report was saved. To save a report in the future, please set a valid directory in the <b>REPORT_SAVE_PATH</b> variable at the top of this script."
    fi
  fi
  echo "---"
}

# --- Run main ---
main "$@"