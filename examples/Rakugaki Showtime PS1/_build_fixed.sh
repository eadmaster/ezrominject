
INPUT_ROM="Rakugaki Showtime (Japan).bin"
OUTPUT_ROM="Rakugaki Showtime (English).bin"

cp "$INPUT_ROM" "$OUTPUT_ROM"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM"
# TODO: fix 00, 0R escape codes
#NOT SUPORTED: --ascii-mode

#xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"
