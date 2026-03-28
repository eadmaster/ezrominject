
INPUT_ROM="Basted (Japan) (Track 02).bin"
OUTPUT_ROM="Basted (Japan) (Track 02) (patched).bin"

# strip ecc data
bchunk-bin2iso -t 00:03:00 "$INPUT_ROM" "$OUTPUT_ROM"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM"  --ascii-bios-hack 
#NOT COMPATIBLE: --ascii-mode
# MEMO: need to skip control code: " 娃=0x88a1"

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$INPUT_ROM.xdelta"
