
INPUT_ROM="In Magical Adventure - Fray CD - Xak Gaiden (Japan) (Track 02).bin"
OUTPUT_ROM="In Magical Adventure - Fray CD - Xak Gaiden (Japan) (Track 02) (patched).bin"

cp "$INPUT_ROM" "$OUTPUT_ROM.tmp"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM.tmp" --ascii-bios-hack 
# NOT SUPPORTED: ascii mode
# MEMO: need to skip control code: " 娃=0x88a1"

# patch locations in menus
rominject.py *_jap.txt *_eng_retrosub.txt "$OUTPUT_ROM.tmp"

# strip ecc data
bchunk-bin2iso -t 00:02:74 "$OUTPUT_ROM.tmp" "$OUTPUT_ROM"
rm "$OUTPUT_ROM.tmp"

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$INPUT_ROM.xdelta"