
INPUT_ROM="In Magical Adventure - Fray CD - Xak Gaiden (Japan) (Track 02).bin"
OUTPUT_ROM="In Magical Adventure - Fray CD - Xak Gaiden (Japan) (Track 02) (patched).bin"

# strip ecc data
bchunk-bin2iso -t 00:02:74 "$INPUT_ROM" "$OUTPUT_ROM"


rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM" --ascii-bios-hack 
# NOT SUPPORTED: ascii mode
# MEMO: need to skip control code: " 娃=0x88a1"

# patch gfx
#sfk partcopy "$OUTPUT_ROM" -fromto 0x18e8 0x1c28 gfx/loading_banner_jap.bin -yes
#TODO: sfk partcopy "$OUTPUT_ROM" -fromto ... gfx/menu_jap.bin -yes

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$INPUT_ROM.xdelta"
