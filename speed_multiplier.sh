#!/usr/bin/env bash
#
# Video Speed Multiplier (Bash & FFmpeg)
# Bash port of SpeedMultiplier.ps1
#
# Usage:
#   ./speed_multiplier.sh
#   ./speed_multiplier.sh -i "/videos/lesson.mp4" -s 1.75
#   ./speed_multiplier.sh --input "/videos/lesson.mp4" --speed 1.75
#

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

InputFile=""
Speed=""

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--input|-InputFile)
            InputFile="$2"
            shift 2
            ;;
        -s|--speed|-Speed)
            Speed="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown argument: $1${NC}"
            shift
            ;;
    esac
done

# 1. Auto-detect video if no parameter is provided
if [[ -z "$InputFile" ]]; then
    echo -e "${CYAN}No input file provided. Scanning current directory...${NC}"

    # Search for the most recently modified .mp4 or .mkv file in the current folder
    DetectedFile=$(find . -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" \) -printf '%T@ %p\n' 2>/dev/null \
                    | sort -rn | head -n 1 | cut -d' ' -f2-)

    if [[ -n "$DetectedFile" ]]; then
        InputFile="$DetectedFile"
        echo -e "${GREEN}Auto-detected newest video: $(basename "$DetectedFile")${NC}"
    else
        echo -e "${YELLOW}No .mp4 or .mkv files found in the current directory.${NC}"
        while [[ -z "$InputFile" || ! -f "$InputFile" ]]; do
            read -rp "Please enter the full path to your video file: " InputFile
            if [[ ! -f "$InputFile" ]]; then
                echo -e "${RED}File not found! Please try again.${NC}"
            fi
        done
    fi
fi

# 2. Handle Speed Selection Menu if no speed parameter was forced
if [[ -z "$Speed" ]]; then
    echo -e "\n${CYAN}Select your playback speed multiplier:${NC}"
    echo "1) 1.25x"
    echo "2) 1.5x"
    echo "3) 1.75x"
    echo "4) 2.0x (Default)"

    read -rp "Enter option number [1-4] or press Enter for default: " Choice

    case "$Choice" in
        1) Speed=1.25 ;;
        2) Speed=1.5 ;;
        3) Speed=1.75 ;;
        4) Speed=2.0 ;;
        "") Speed=2.0 ;;
        *)
            echo -e "${YELLOW}Invalid choice. Using default 2.0x speed.${NC}"
            Speed=2.0
            ;;
    esac
fi

# Ensure the final path is fully resolved
InputFile="$(cd "$(dirname "$InputFile")" && pwd)/$(basename "$InputFile")"
Extension=".${InputFile##*.}"
Directory="$(dirname "$InputFile")"
FileNameWithoutExt="$(basename "$InputFile" "$Extension")"

# Prepare output file name
OutputFile="${Directory}/${FileNameWithoutExt}_${Speed}x${Extension}"

# Calculate FFmpeg speed multipliers
VideoSpeed=$(awk "BEGIN {print 1/$Speed}")
AudioSpeed="$Speed"

# Build the FFmpeg audio filter string
AtempoFilters=()
RemainingAudioSpeed="$AudioSpeed"

while awk "BEGIN {exit !($RemainingAudioSpeed > 2.0)}"; do
    AtempoFilters+=("atempo=2.0")
    RemainingAudioSpeed=$(awk "BEGIN {print $RemainingAudioSpeed/2.0}")
done
AtempoFilters+=("atempo=$RemainingAudioSpeed")

AudioFilterString=$(IFS=,; echo "${AtempoFilters[*]}")

# Formulate the complex filter for FFmpeg
FilterComplex="[0:v]setpts=${VideoSpeed}*PTS[v];[0:a]${AudioFilterString}[a]"

echo -e "\n${CYAN}Processing: $InputFile${NC}"
echo -e "${CYAN}Target Speed: ${Speed}x${NC}"
echo -e "${CYAN}Output File: $OutputFile${NC}"
echo -e "${YELLOW}Running FFmpeg... Please wait.${NC}\n"

# Execute FFmpeg
ffmpeg -i "$InputFile" -filter_complex "$FilterComplex" -map "[v]" -map "[a]" -y "$OutputFile"

if [[ $? -eq 0 ]]; then
    echo -e "\n${GREEN}Success! Video saved to: $OutputFile${NC}"
else
    echo -e "\n${RED}Error: FFmpeg failed to process the video.${NC}"
fi
