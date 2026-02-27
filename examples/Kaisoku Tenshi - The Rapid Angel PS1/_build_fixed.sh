
INPUT_ROM="Kaisoku Tenshi - The Rapid Angel (Japan) (Track 1).bin"
OUTPUT_ROM="Kaisoku Tenshi - The Rapid Angel (Japan) (Track 1) (patched).bin"

cp "$INPUT_ROM" "$OUTPUT_ROM"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM"

#xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"



