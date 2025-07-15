# Unraid Movie Folder Media Audit 

This is a simple but effective script for auditing your movie share on Unraid to identify folders that contain more than one media file. It’s useful for spotting messy or mismanaged movie folders, especially in cases where multiple video files have been placed in the same directory.

This is not a traditional duplicate detector as it doesn’t compare filenames, hashes, or metadata. Instead, it flags folders that contain multiple video files (e.g. `.mkv`, `.mp4`, etc.), helping you spot potential issues that most media managers won’t detect.

## What It Does

- Scans a movie directory (non-recursively by default)
- Finds folders that contain more than one video file
- Displays the folder path and file sizes in the User Scipts webUI
- Optionally saves the results to a text file

This script pairs well with media tools like Emby, Jellyfin, or Plex 

## Example Use Case

Imagine the following folder structure-

```
/mnt/user/Movies/Plan 9 from Outer Space (1959)/
├── Plan9.mkv
└── NightOfTheLivingDead.mp4
```

Your media server might show both movies, or just recognise the folder as containing Plan 9, depending on how it's scanned. This script will flag the folder because it contains two separate movie files, which likely don’t belong together.

It also works in cases where the files are alternate versions of the same movie, such as-

```
/mnt/user/Movies/The Brain That Wouldn’t Die/
├── TheBrain.mkv              
└── TheBrain1962.mp4          
```

Whether these are different encodes, editions, or accidental duplicates, this script will detect the folder as containing multiple video files, prompting you to review and tidy it up manually.

## Configuration

Edit the top section of the script to set your paths-

```bash
ROOT_DIR="/mnt/user/Movies"         # Folder to scan
REPORT_SAVE_PATH="/mnt/user/temp"   # Optional: where to save a text report
RECURSIVE="no"                      # Set to "yes" to scan recursively
INCLUDE_HIDDEN="no"                 # Set to "yes" to include hidden folders
```

Supported media file extensions:
- `.mp4`, `.mkv`, `.avi`, `.mov`, `.wmv`, `.flv`, `.webm`

## How to Use

1. Install the User Scripts plugin (if not already installed)
2. Create a new script
3. Paste the full script code
4. Adjust the paths as needed
5. Run the script manually


## Notes

- This script doesn’t delete anything — it’s read-only

## Feedback

Suggestions, improvements, or corrections? Feel free to open an issue or send a pull request.
