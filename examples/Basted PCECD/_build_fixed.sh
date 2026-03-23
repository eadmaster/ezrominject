
INPUT_ROM="Basted (Japan) (Track 02).bin"
OUTPUT_ROM="Basted (Japan) (Track 02) (patched).bin"

cp "$INPUT_ROM" "$OUTPUT_ROM"

# MEMO: need to skip control code: " 娃=0x88a1"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM"  --ascii-bios-hack 
#NOT COMPATIBLE: --ascii-mode

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"
