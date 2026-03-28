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
    repeat_block 0xf3e6a3 0x22e782 1128  "$OUTPUT_ROM"  # items in submenu 
    
    repeat_block 0x2851f0 0x2351b6   72  "$OUTPUT_ROM"  # shop menu1
    repeat_block 0x2852ae 0x235274 2382  "$OUTPUT_ROM"  # shop items
    repeat_block 0x29d019 0x24d019  520  "$OUTPUT_ROM"  # shop menu2
    repeat_block 0x43d019 0x3ed019  463  "$OUTPUT_ROM"  # shop menu3 -> TODO: test
    
    # variations: 
    repeat_block 0x8351e2 0x2351b6   72  "$OUTPUT_ROM"  # shop menu1 (alt) -> TODO: test
    repeat_block 0x63d019 0x24d019  520  "$OUTPUT_ROM"  # shop menu2 (alt) -> TODO: test
    repeat_block 0x6dd019 0x24d019  520  "$OUTPUT_ROM"  # shop menu2 (alt) -> TODO: test
    repeat_block 0x821098 0x235274 2380  "$OUTPUT_ROM"  # shop items (alt. smaller) -> TODO: test
    repeat_block 0x8352a0 0x235274 2380  "$OUTPUT_ROM"  # shop items (alt. smaller) -> TODO: test
}

patch_gfx() {
    echo "patch_gfx:"
    # extract
    #sfk partcopy "$OUTPUT_ROM" -fromto 0x1060860 0x10616c0 gfx/locations_jap.bin -yes
    #TODO: sfk partcopy "$OUTPUT_ROM" -fromto ... gfx/menu_jap.bin -yes
    # replace
    #repeat_block ...
}


# jap dub build

INPUT_ROM="PopfulMail (Japan) (Track 02).bin"
OUTPUT_ROM="PopfulMail (Japan) (Track 02) (patched).bin"

cp "$INPUT_ROM" "$OUTPUT_ROM.tmp"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM.tmp"  --ascii-bios-hack 
#NOT COMPATIBLE: --ascii-mode

# strip ecc data
bchunk-bin2iso -t 00:03:00 "$OUTPUT_ROM.tmp" "$OUTPUT_ROM"
rm "$OUTPUT_ROM.tmp"

patch_repeated_blocks

patch_gfx

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$INPUT_ROM.xdelta"


## eng dub build

INPUT_ROM="02 Magical Fantasy Adventure - Popful Mail (J).bin"
OUTPUT_ROM="02 Magical Fantasy Adventure - Popful Mail (J) (patched).bin"

cp "$INPUT_ROM" "$OUTPUT_ROM.tmp"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM.tmp"  --ascii-bios-hack 
#NOT COMPATIBLE: --ascii-mode

# strip ecc data
bchunk-bin2iso -t 00:03:00 "$OUTPUT_ROM.tmp" "$OUTPUT_ROM"
rm "$OUTPUT_ROM.tmp"

patch_repeated_blocks

patch_gfx

xdelta3 -S none -f -e -s "02 Magical Fantasy Adventure - Popful Mail (J).iso" "$OUTPUT_ROM"  "$INPUT_ROM.xdelta"
