#!/bin/bash

INPUT_ROM="In Magical Adventure - Fray CD - Xak Gaiden (Japan) (Track 02).bin"
OUTPUT_ROM="In Magical Adventure - Fray CD - Xak Gaiden (Japan) (Track 02) (patched).bin"

# strip ecc data
bchunk-bin2iso -t 00:02:74 "$INPUT_ROM" "$OUTPUT_ROM"

# patch text
rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM" --ascii-bios-hack 
# NOT SUPPORTED: ascii mode
# MEMO: need to skip control code: " 娃=0x88a1"

# extract+replace gfx
# (tiles format: 8x8 4bpp SNES)
mkdir -p gfx
sfk partcopy "$OUTPUT_ROM" -fromto 0x18e8 0x1c28 gfx/loading_banner_jap.bin -yes
sfk partcopy "$OUTPUT_ROM" -fromto 0x13F780 0x13F820 gfx/menu_status_jap.bin -yes  # ステータス -> HP
sfk partcopy "$OUTPUT_ROM" -fromto 0x13F820 0x13F880 gfx/menu_shield_part_jap.bin -yes   # シルド (part of シールド)
sfk partcopy "$OUTPUT_ROM" -fromto 0x13F880 0x13F8C0 gfx/menu_gold_part_jap.bin -yes  # ゴー (part of ゴールド) -> GO
sfk partcopy "$OUTPUT_ROM" -fromto 0x13F8C0 0x13F920 gfx/menu_item_part_jap.bin -yes  # アイム (part of アイテム) -> IT_M  -> TODO: change ITEM
sfk partcopy "$OUTPUT_ROM" -fromto 0x13F920 0x13F9a0 gfx/menu_magic_jap.bin -yes  # マジック -> MAG[IC]/SPELL
sfk partcopy "$OUTPUT_ROM" -fromto 0x13FAE0 0x13Fb40 gfx/menu_rod_jap.bin -yes  # ロッド -> ROD
sfk partcopy "$OUTPUT_ROM" -fromto 0x13Fb40 0x13Fbc0 gfx/menu_heal_jap.bin -yes  # カイフク -> HEAL
sfk partcopy "$OUTPUT_ROM" -fromto 0x13Fbc0 0x13Fc60 gfx/menu_teleport_jap.bin -yes  # テレポート -> TELEP

replace_gfx() {
    FILEBASENAME=gfx/$1
    ORIG_BLOCK_HEX=$(sfk hexdump -raw ${FILEBASENAME}_jap.bin)
    REPL_BLOCK_HEX=$(sfk hexdump -raw ${FILEBASENAME}_eng.bin)
    # binary search-replace   https://stahlworks.com/sfk-rep
    sfk replace "$OUTPUT_ROM" -binary /$ORIG_BLOCK_HEX/$REPL_BLOCK_HEX/  -yes
}

replace_gfx menu_status
replace_gfx menu_item_part
replace_gfx menu_magic
replace_gfx menu_gold_part
replace_gfx menu_shield_part
replace_gfx menu_rod
replace_gfx menu_heal
replace_gfx menu_teleport

# 1HitKil cheat  https://gamehacking.org/game/84576
#sfk setbytes "$OUTPUT_ROM" 0x11389B 0xA900 -yes

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$INPUT_ROM.xdelta"
