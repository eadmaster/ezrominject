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

    #repeat_block 0x2851f0 0x2351b6   72  "$OUTPUT_ROM"  # shop menu1
    #repeat_block 0x2852ae 0x235274 2382  "$OUTPUT_ROM"  # shop items
    #repeat_block 0x29d019 0x24d019  520  "$OUTPUT_ROM"  # shop menu2
    #repeat_block 0x43d019 0x3ed019  463  "$OUTPUT_ROM"  # shop menu3 -> TODO: test
    # variations: 
    #repeat_block 0x8351e2 0x2351b6   72  "$OUTPUT_ROM"  # shop menu1 (alt) -> TODO: test
    #repeat_block 0x63d019 0x24d019  520  "$OUTPUT_ROM"  # shop menu2 (alt) -> TODO: test
    #repeat_block 0x6dd019 0x24d019  520  "$OUTPUT_ROM"  # shop menu2 (alt) -> TODO: test
    #repeat_block 0x821098 0x235274 2380  "$OUTPUT_ROM"  # shop items (alt. smaller) -> TODO: test
    #repeat_block 0x8352a0 0x235274 2380  "$OUTPUT_ROM"  # shop items (alt. smaller) -> TODO: test
}
    

extract_gfx() {
    mkdir -p gfx
    
    # locations
    sfk partcopy "$OUTPUT_ROM" -fromto 0x10608D1 0x1060951 gfx/location_elf_forest_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060951 0x10609D1 gfx/location_tree_tower_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x10609D1 0x1060A51 gfx/location_golem_tower_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060A51 0x1060AD1 gfx/location_wind_cave_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060AD1 0x1060B51 gfx/location_fossil_cave_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060B51 0x1060BD1 gfx/location_spring_cave_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060BD1 0x1060C51 gfx/location_monster_lair_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060C51 0x1060CD1 gfx/location_golaides_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060CD1 0x1060D51 gfx/location_mines_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060D51 0x1060DD1 gfx/location_ancient_temple_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060DD1 0x1060E51 gfx/location_zeimar_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060E51 0x1060ED1 gfx/location_false_wilderness_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060ED1 0x1060F51 gfx/location_tower_deception_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060F51 0x1060FD1 gfx/location_castle_illusion_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1060FD1 0x1061051 gfx/location_ship_graveyard_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1061051 0x10610D1 gfx/location_underwater_temple_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x10610D1 0x1061151 gfx/location_undersea_palace_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1061151 0x10611D1 gfx/location_otherworld_city_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x10611D1 0x1061251 gfx/location_assembly_plant_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1061251 0x10612D1 gfx/location_dimensional_fortress_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x10612D1 0x1061351 gfx/location_iceberg_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1061351 0x10613D1 gfx/location_mt_rip_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x10613D1 0x1061451 gfx/location_rap_ship_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1061451 0x10614D1 gfx/location_crystal_temple_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x10614D1 0x1061551 gfx/location_front_gate_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1061551 0x10615D1 gfx/location_treasury_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x10615D1 0x1061651 gfx/location_underground_maze_jap.bin -yes
    sfk partcopy "$OUTPUT_ROM" -fromto 0x1061651 0x10616D1 gfx/location_sealed_palace_jap.bin -yes
    
    # menus
    sfk partcopy "$OUTPUT_ROM" -fromto 0x2e3afd 0x2e3d02 gfx/menu_pause1_jap.bin -yes  # multi char overworld ver.
    sfk partcopy "$OUTPUT_ROM" -fromto 0x2e3d02 0x2e3ef0 gfx/menu_pause2_jap.bin -yes  # single char overworld ver.
    sfk partcopy "$OUTPUT_ROM" -fromto 0x2e3ef0 0x2e40e3 gfx/menu_pause3_jap.bin -yes  # multi-char underworld ver.
    sfk partcopy "$OUTPUT_ROM" -fromto 0x2940e3 0x2942ad gfx/menu_pause4_jap.bin -yes  # single-char underworld ver
    # TODO: menu_save, menu_load, menu_confirm
    #TODO: sfk partcopy "$OUTPUT_ROM" -fromto 0x1680400 0x gfx/_sound_test_menu_jap.bin -yes
}

replace_gfx() {
    FILEBASENAME=gfx/$1
    [ ! -f ${FILEBASENAME}_eng.bin ] && return  # replacement file missing
    ORIG_BLOCK_HEX=$(sfk hexdump -raw ${FILEBASENAME}_jap.bin)
    REPL_BLOCK_HEX=$(sfk hexdump -raw ${FILEBASENAME}_eng.bin)
    # binary search-replace   https://stahlworks.com/sfk-rep
    sfk replace "$OUTPUT_ROM" -binary /$ORIG_BLOCK_HEX/$REPL_BLOCK_HEX/  -yes
}

patch_gfx() {
    replace_gfx location_elf_forest
    replace_gfx location_tree_tower
    replace_gfx location_golem_tower
    replace_gfx location_wind_cave
    replace_gfx location_fossil_cave
    replace_gfx location_spring_cave
    replace_gfx location_monster_lair
    replace_gfx location_golaides
    replace_gfx location_mines
    replace_gfx location_ancient_temple
    replace_gfx location_zeimar
    replace_gfx location_false_wilderness
    replace_gfx location_tower_deception
    replace_gfx location_castle_illusion
    replace_gfx location_ship_graveyard
    replace_gfx location_underwater_temple
    replace_gfx location_undersea_palace
    replace_gfx location_otherworld_city
    replace_gfx location_assembly_plant
    replace_gfx location_dimensional_fortress
    replace_gfx location_iceberg
    replace_gfx location_mt_rip
    replace_gfx location_rap_ship
    replace_gfx location_crystal_temple
    replace_gfx location_front_gate
    replace_gfx location_treasury
    replace_gfx location_underground_maze
    replace_gfx location_sealed_palace
    
    #truncate --reference=menu_pause_jap.bin menu_pause1_eng.bin  # fill with 0s to match the original block size

    replace_gfx menu_pause1
    replace_gfx menu_pause2
    replace_gfx menu_pause3
    replace_gfx menu_pause4
}


# jap dub build

INPUT_ROM="PopfulMail (Japan) (Track 02).bin"
OUTPUT_ROM="PopfulMail (Japan) (Track 02) (patched).bin"

# strip ecc data
../../bchunk-bin2iso/bchunk-bin2iso -t 00:03:00  "$INPUT_ROM" "$OUTPUT_ROM"

# patch text
python ../../ezrominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM"  --ascii-bios-hack 
#NOT COMPATIBLE: --ascii-mode

patch_repeated_blocks "$OUTPUT_ROM"

#[ ! -d "gfx" ] && 
extract_gfx

patch_gfx

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$INPUT_ROM.xdelta"


## eng dub build

INPUT_ROM="02 Magical Fantasy Adventure - Popful Mail (J).iso"
OUTPUT_ROM="02 Magical Fantasy Adventure - Popful Mail (J) (patched).bin"

cp "$INPUT_ROM" "$OUTPUT_ROM"

python ../../ezrominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM"  --ascii-bios-hack 
#NOT COMPATIBLE: --ascii-mode

patch_repeated_blocks "$OUTPUT_ROM"

patch_gfx

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$INPUT_ROM.xdelta"
