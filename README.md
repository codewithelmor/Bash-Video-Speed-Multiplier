# Video Speed Multiplier (Bash Script)

A native **Bash script** for Linux/macOS environments to quickly adjust video playback speeds via **FFmpeg**. The script handles both interactive menu selection and automated batch command-line arguments flawlessly.

## Features
* **Smart Auto-Detection:** Scans the active folder for the most recently updated `.mp4` or `.mkv` file if an explicit path isn't provided.
* **Flexible Execution:** Supports interactive menus or automated script parameters (`-i`/`--input` and `-s`/`--speed`).
* **Advanced Audio Chains:** Safely bypasses default FFmpeg constraints on the `atempo` filter by dynamically chaining audio rules for higher speeds.
* **Visual Color Indicators:** Employs color-coded terminal alerts (Cyan, Green, Yellow, Red) for intuitive operation monitoring.

## Prerequisites
1. **Bash** (Available by default on Linux and macOS)
2. **FFmpeg** (Must be accessible from your system `PATH`)
3. **awk** (Used for floating-point math; included by default on virtually all Linux/macOS systems)

## Installation & Setup
1. Place `speed_multiplier.sh` into the folder containing your video(s), or anywhere on your system.
2. Make the script executable:
   ```bash
   chmod +x speed_multiplier.sh
   ```

## How to Use

### Method 1: Interactive Menu (Standard)
1. Open a terminal in the directory containing your script and video.
2. Launch the script:
   ```bash
   ./speed_multiplier.sh
   ```
3. The script will look for the newest `.mp4`/`.mkv` file. If one isn't found, it prompts you to paste the full path.
4. Choose your speed setting via the numbered terminal menu options.

### Method 2: Automated Script Arguments
Bypass all interactive menus entirely by specifying parameters directly in your shell call:
```bash
./speed_multiplier.sh -i "/videos/lesson.mp4" -s 1.75
```

You can also use the long-form flags:
```bash
./speed_multiplier.sh --input "/videos/lesson.mp4" --speed 1.75
```

## Output
The updated file is saved directly next to the original file, labeled with its new playback speed suffix (e.g., `lesson_1.75x.mp4`).
