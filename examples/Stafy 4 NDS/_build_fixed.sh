#!/bin/bash

INPUT_ROM="Densetsu no Stafy 4 (Japan).nds"
OUTPUT_ROM="Densetsu no Stafy 4 (English).nds"

replace_cell_gfx() {
    [ -f gfx/$1.NCGR ] && cp -fv gfx/$1.NCGR  "Densetsu no Stafy 4 (Japan)/data/Cell/$1.NCGR"
    [ -f gfx/$1.NCER ] && cp -fv gfx/$1.NCER  "Densetsu no Stafy 4 (Japan)/data/Cell/$1.NCER"
}

# extract rom with NitroPacker https://github.com/haroohie-club/NitroPacker
[ ! -d "Densetsu no Stafy 4 (Japan)" ] && NitroPacker unpack -r "$INPUT_ROM" -o "Densetsu no Stafy 4 (Japan)" -p "Densetsu no Stafy 4 (English)"
# alt.: with dsrom https://github.com/AetiasHax/ds-rom
#[ ! -d "Densetsu no Stafy 4 (Japan)" ] && dsrom extract --rom "$INPUT_ROM" --path "Densetsu no Stafy 4 (Japan)"

# replace fonts
cp Font/stafy4_13b2_full_bmp_comb_clean.bin  "Densetsu no Stafy 4 (Japan)/data/Font/stafy4_13b2_full_bmp.bin"
cp Font/stafy4_13b2_2_bmp_comb_clean.bin  "Densetsu no Stafy 4 (Japan)/data/Font/stafy4_13b2_2_bmp.bin"

replace_cell_gfx title_ue_ob_font  # "Press Start!" on title screen
replace_cell_gfx title_sita_ob_font  # "Start" on title screen
replace_cell_gfx save_window_l  # "Save now?" window (used in stages)
replace_cell_gfx save_obj  # "Save now?" window (autosave after bosses)
replace_cell_gfx city1_obj_sub_l  # 1st city map ui elements
replace_cell_gfx fileselect_low_obj  # File menu on title screen
replace_cell_gfx city_in_l  # "[Back] To City" sign in stages
replace_cell_gfx pose_obj_l  # Pause menu
replace_cell_gfx fukidashi_00_l  # Press Button X
replace_cell_gfx gameover_obj_1  # Game Over menu: Retry / Quit

# replace boss speech stored as gfx
cd gfx
for f in bossmess_*_l.NCGR bossmess_*_l.NCER; do
    cp -fv "$f" "../Densetsu no Stafy 4 (Japan)/data/Boss/"
done
cd ..

# replace King Warp Jizou prompts
# TODO: try reusing the same file with other stages too
cd gfx
for f in jizou_st*_l.NCGR jizou_st*_l.NCER; do
    NUMBER=$(echo "$f" | cut -d'_' -f2 | sed 's/st//')  # get stage number
    cp -fv "$f" "../Densetsu no Stafy 4 (Japan)/data/Stage$NUMBER/"
done
cd ..

# extract and patch map legend embedded gfx inside the overlay
# sfk partcopy "Densetsu no Stafy 4 (Japan)/overlay/main_0013.bin" 0x11B810 0x2426 gfx/811B810_lzss_jap.bin -yes  # extract original gfx
# sfk partcopy "Densetsu no Stafy 4 (Japan)/overlay/main_0013.bin" 0x11DC38 0x1A9 811DC38_lzss.bin -yes  # extract palette
# cp /r/811B810_lzss_eng_unpadded.bin gfx/811B810_lzss_eng.bin 
# truncate --reference gfx/811B810_lzss_jap.bin gfx/811B810_lzss_eng.bin  # add padding
sfk partcopy gfx/811B810_lzss_eng.bin 0x0 0x2426 "Densetsu no Stafy 4 (Japan)/overlay/main_0013.bin" 0x11B810  -yes  # patch

# repack with custom font and gfx
NitroPacker pack -p "Densetsu no Stafy 4 (Japan)/Densetsu no Stafy 4 (English).json" -r "$OUTPUT_ROM"
# alt.: dsrom build --config "Densetsu no Stafy 4 (Japan)/config.yaml" --rom "$OUTPUT_ROM"

# patch text
sed "s/'/｀/g; s/-/ー/g; s/+/＋/g; s/</＜/g; s/>/＞/g; s/\"/″/g; s/“/″/g; s/”/″/g;" *_eng.txt > /tmp/eng.txt  # ensure supported symbols
python ../../ezrominject.py *_jap.txt "/tmp/eng.txt" "$OUTPUT_ROM" --ascii-bios-hack
#NOT WORKING: --ascii-mode

# patch game Banner Title (utf16le-encoded, multiple occurrences) でんせつのスタフィー4  -> Ｓｔａｒｆｙ－４
sfk replace "$OUTPUT_ROM" -binary /673093305B3064306E30B930BF30D530A330FC3034/33FF54FF41FF52FF46FF59FF0DFF14FF0000000000/  -yes

# generate xdelta patch
xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"
