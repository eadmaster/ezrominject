
INPUT_ROM="Star Hearts - Hoshi to Daichi no Shisha (Japan).wsc"
OUTPUT_ROM="Star Hearts - Hoshi to Daichi no Shisha (English).wsc"

cp "$INPUT_ROM" "$OUTPUT_ROM"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM"  # NOT SUPPORTED: --ascii-mode

#xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"



