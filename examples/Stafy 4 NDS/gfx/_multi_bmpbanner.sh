#!/bin/bash

if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $(basename "$0") <input_txt_file> [output_image.png]"
    echo
    echo "Environment Variables for Customization:"
    echo "  OUTPUT_WIDTH : Canvas width in pixels (default: 256)"
    echo "  LINE_HEIGHT  : Line height in pixels (default: 16)"
    echo "  BG_COLOR     : Output background color (default: none / transparent)"
    echo "  FG_COLOR1    : New foreground color 1 (optional)"
    echo "  SRC_COLOR1   : Source color to replace with FG_COLOR1 (default: white)"
    echo "  FG_COLOR2    : New foreground color 2 (optional)"
    echo "  SRC_COLOR2   : Source color to replace with FG_COLOR2 (default: black)"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-/tmp/output_banner.png}"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found."
    return 1
fi

# Configurable variables (can be overridden via environment or edited here)
OUTPUT_WIDTH="${OUTPUT_WIDTH:-256}"
LINE_HEIGHT="${LINE_HEIGHT:-16}"
BG_COLOR="${BG_COLOR:-none}"

# Optional Foreground Color Replacements
FG_COLOR1="${FG_COLOR1:-}"        # Replacement color 1 (e.g., "#FF0000" or "red")
SRC_COLOR1="${SRC_COLOR1:-white}" # Source color to replace

FG_COLOR2="${FG_COLOR2:-}"        # Replacement color 2 (e.g., "#00FF00" or "green")
SRC_COLOR2="${SRC_COLOR2:-black}" # Source color to replace

# valkyrie no bouken cutscenses
BG_COLOR="#210009"
SRC_COLOR1="#ffffff" ; FG_COLOR1="#f95cf0"  # white to pink
SRC_COLOR2="#000000" ; FG_COLOR2="#0300ff"  # black to blue

TMP_FILES=()
LINE_NO=1

# Read line-by-line from input text file
while IFS= read -r LINE || [ -n "$LINE" ]; do
    TMP_IMG="/tmp/${LINE_NO}.png"
    
    # Invoke _bmpbanner.sh for each line
    ./_bmpbanner.sh "$LINE" "$TMP_IMG"
    
    # Adjust line height using canvas extent
    if [ -f "$TMP_IMG" ]; then
        convert "$TMP_IMG" -background "$BG_COLOR" -gravity west -extent "${OUTPUT_WIDTH}x${LINE_HEIGHT}" "$TMP_IMG"
        TMP_FILES+=("$TMP_IMG")
    fi

    ((LINE_NO++))
done < "$INPUT_FILE"

if [ ${#TMP_FILES[@]} -eq 0 ]; then
    echo "Error: No lines processed."
    exit 1
fi

# Build ImageMagick color replacement flags if specified
COLOR_OPTS=()
if [ -n "$FG_COLOR1" ]; then
    COLOR_OPTS+=(-fill "$FG_COLOR1" -opaque "$SRC_COLOR1")
fi
if [ -n "$FG_COLOR2" ]; then
    COLOR_OPTS+=(-fill "$FG_COLOR2" -opaque "$SRC_COLOR2")
fi

# Build background / alpha handling flags
BG_OPTS=(-background "$BG_COLOR")
if [ "$BG_COLOR" != "none" ] && [ "$BG_COLOR" != "transparent" ]; then
    BG_OPTS+=(-alpha remove -alpha off)
fi

# Merge lines vertically and apply background / color options
convert -append "${TMP_FILES[@]}" -background "$BG_COLOR" "${COLOR_OPTS[@]}" "${BG_OPTS[@]}" "$OUTPUT_FILE"

# Clean up temporary line images
rm -f "${TMP_FILES[@]}"

echo "Multi-line banner saved to $OUTPUT_FILE"