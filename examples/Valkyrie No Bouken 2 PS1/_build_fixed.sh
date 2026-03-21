
INPUT_ROM="Namco Anthology 2 (Japan).bin"
OUTPUT_ROM="Namco Anthology 2 (Japan) (patched).bin"

cp "$INPUT_ROM" "$OUTPUT_ROM"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM" --ascii-bios-hack

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"
