
INPUT_ROM="Moonlight Lady (Japan) (Track 02).bin"
OUTPUT_ROM="Moonlight Lady (Japan) (Track 02) (patched).bin"

cp "$INPUT_ROM" "$OUTPUT_ROM"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM" --kana-1-byte  --ascii-bios-hack 

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"



