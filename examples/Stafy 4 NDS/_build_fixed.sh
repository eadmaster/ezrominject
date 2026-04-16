#!/bin/bash

INPUT_ROM="Densetsu no Stafy 4 (Japan).nds"
OUTPUT_ROM="Densetsu no Stafy 4 (English).nds"

# OLD: patch font
#./nds-replace.py "$INPUT_ROM" Font/stafy4_13b2_full_bmp.bin Font/stafy4_13b2_full_bmp_comb_clean.bin -o "/tmp/$OUTPUT_ROM"
#./nds-replace.py "/tmp/$OUTPUT_ROM" Font/stafy4_13b2_2_bmp.bin Font/stafy4_13b2_2_bmp_comb_clean.bin -o "$OUTPUT_ROM"
#TODO: ./nds-replace.py "$INPUT_ROM" Font/stafy2_9b2_small_bmp.bin ... -o "$OUTPUT_ROM"

replace_gfx() {
    [ -f gfx/$1.NCGR ] && cp -fv gfx/$1.NCGR  "Densetsu no Stafy 4 (Japan)/data/Cell/$1.NCGR"
    [ -f gfx/$1.NCER ] && cp -fv gfx/$1.NCER  "Densetsu no Stafy 4 (Japan)/data/Cell/$1.NCER"
}

# repack with custom font and gfx with dsrom https://github.com/AetiasHax/ds-rom
#[ ! -d "Densetsu no Stafy 4 (Japan)" ] && dsrom extract --rom "$INPUT_ROM" --path "Densetsu no Stafy 4 (Japan)"
#cp Font/stafy4_13b2_full_bmp_comb_clean.bin  "Densetsu no Stafy 4 (Japan)/files/Font/stafy4_13b2_full_bmp.bin"
#cp Font/stafy4_13b2_2_bmp_comb_clean.bin  "Densetsu no Stafy 4 (Japan)/files/Font/stafy4_13b2_2_bmp.bin"
#dsrom build --config "Densetsu no Stafy 4 (Japan)/config.yaml" --rom "$OUTPUT_ROM"

# repack with custom font and gfx with NitroPacker https://github.com/haroohie-club/NitroPacker
[ ! -d "Densetsu no Stafy 4 (Japan)" ] && NitroPacker unpack -r "$INPUT_ROM" -o "Densetsu no Stafy 4 (Japan)" -p "Densetsu no Stafy 4 (English)"

cp Font/stafy4_13b2_full_bmp_comb_clean.bin  "Densetsu no Stafy 4 (Japan)/data/Font/stafy4_13b2_full_bmp.bin"
cp Font/stafy4_13b2_2_bmp_comb_clean.bin  "Densetsu no Stafy 4 (Japan)/data/Font/stafy4_13b2_2_bmp.bin"

replace_gfx title_ue_ob_font  # "Press Start button!" on title screen
replace_gfx title_sita_ob_font  # "Start" on title screen
replace_gfx save_obj  # "Save now?" window (used in ??)
replace_gfx save_window_l  # "Save now?" window (used in stages)
#TODO: replace_gfx fileselect_low_obj  # File menu

NitroPacker pack -p "Densetsu no Stafy 4 (Japan)/Densetsu no Stafy 4 (English).json" -r "$OUTPUT_ROM"

# patch text
sed "s/'/´/g; s/'/´/g"  *_eng.txt > "/tmp/eng.txt"  # ensure supported chars
python ../../ezrominject.py *_jap.txt "/tmp/eng.txt" "$OUTPUT_ROM" --ascii-bios-hack
#NOT WORKING: --ascii-mode

# generate xdelta patch
xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"
