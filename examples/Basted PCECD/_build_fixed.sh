
INPUT_ROM="Basted (Japan) (Track 02).bin"
OUTPUT_ROM="Basted (Japan) (Track 02) (patched).bin"

cp "$INPUT_ROM" "$OUTPUT_ROM.tmp"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM.tmp"  --ascii-bios-hack 
#NOT COMPATIBLE: --ascii-mode
# MEMO: need to skip control code: " 娃=0x88a1"

# strip ecc data
bchunk-bin2iso -t 00:03:00 "$OUTPUT_ROM.tmp" "$OUTPUT_ROM"
rm "$OUTPUT_ROM.tmp"

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"
