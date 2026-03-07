
INPUT_ROM="Recca no Honoo - The Game (Japan).gba"
OUTPUT_ROM="Recca no Honoo - The Game (English).gba"

cp "$INPUT_ROM" "$OUTPUT_ROM"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM"  # TODO: fix forced newlines as "%n"
# NOT SUPPORTED: --ascii-mode 

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"



