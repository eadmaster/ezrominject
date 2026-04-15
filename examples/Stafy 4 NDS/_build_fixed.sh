#!/bin/bash

INPUT_ROM="Densetsu no Stafy 4 (Japan).nds"
OUTPUT_ROM="Densetsu no Stafy 4 (English).nds"

# patch font
# TODO: add xdelta font patch + extractor
#./nds-replace.py "$INPUT_ROM" Font/stafy4_13b2_full_bmp.bin Font/stafy4_13b2_full_bmp_ascii_unifont.bin -o "$OUTPUT_ROM"
#./nds-replace.py "$INPUT_ROM" Font/stafy4_13b2_full_bmp.bin Font/stafy4_13b2_full_bmp_fullwidth.bin -o /tmp/s4-fontpatched.nds
./nds-replace.py "$INPUT_ROM" Font/stafy4_13b2_full_bmp.bin Font/stafy4_13b2_full_bmp_comb.bin -o "/tmp/$OUTPUT_ROM"
./nds-replace.py "/tmp/$OUTPUT_ROM" Font/stafy4_13b2_2_bmp.bin Font/stafy4_13b2_2_bmp_comb.bin -o "$OUTPUT_ROM"
#TODO: ./nds-replace.py "$INPUT_ROM" Font/stafy2_9b2_small_bmp.bin ... -o "$OUTPUT_ROM"

# patch gfx
#./nds-replace.py "/tmp/$OUTPUT_ROM" gfx/save_obj.NCGR Cell/save_obj.NCGR -o "$OUTPUT_ROM"


# ensure supported chars
#sed "s/'/´/g; s/'/´/g"  *_eng.txt > "/tmp/$OUTPUT_ROM.txt"

python ../../ezrominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM" --ascii-bios-hack
#NOT WORKING: --ascii-mode

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"