#!/bin/bash

repeat_block() {
    ORIG_BLOCK_OFFSET=$1
    REPL_BLOCK_OFFSET=$2
    LEN=$3
    INPUT_FILE=$4
    
    ORIG_BLOCK_HEX=$(sfk hexdump -raw -offlen $ORIG_BLOCK_OFFSET $LEN "$INPUT_FILE")
    REPL_BLOCK_HEX=$(sfk hexdump -raw -offlen $REPL_BLOCK_OFFSET $LEN "$INPUT_FILE")
		
	# binary search-replace   https://stahlworks.com/sfk-rep
	sfk replace "$INPUT_FILE" -binary /$ORIG_BLOCK_HEX/$REPL_BLOCK_HEX/  -yes 
}

patch_repeated_blocks() {
    repeat_block 0x22e782  0xf3e6a3  1128  "$1"  # items in submenu 
}
    

extract_gfx() {
    mkdir gfx
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060860 0x10616c0 gfx/locations_jap.bin -yes
    #TODO: sfk partcopy "$OUTPUT_ROM" -fromto ... gfx/menu_jap.bin -yes
}

patch_gfx() {
    echo "patch_gfx:"
    #repeat_block ...
}


# jap dub build

INPUT_ROM="PopfulMail (Japan) (Track 02).bin"
OUTPUT_ROM="PopfulMail (Japan) (Track 02) (patched).bin"

# strip ecc data
bchunk-bin2iso -t 00:03:00  "$INPUT_ROM" "$OUTPUT_ROM"

# patch text
rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM"  --ascii-bios-hack 
#NOT COMPATIBLE: --ascii-mode

patch_repeated_blocks "$OUTPUT_ROM"

[ ! -d "gfx" ] && extract_gfx

patch_gfx

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$INPUT_ROM.xdelta"


## eng dub build

INPUT_ROM="02 Magical Fantasy Adventure - Popful Mail (J).iso"
OUTPUT_ROM="02 Magical Fantasy Adventure - Popful Mail (J) (patched).bin"

cp "$INPUT_ROM" "$OUTPUT_ROM"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM"  --ascii-bios-hack 
#NOT COMPATIBLE: --ascii-mode

patch_repeated_blocks "$OUTPUT_ROM"

patch_gfx

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$INPUT_ROM.xdelta"
