
INPUT_ROM="Ueki no Housoku - Jingi Sakuretsu! Nouryokusha Battle (Japan).gba"
OUTPUT_ROM="Ueki no Housoku - Jingi Sakuretsu! Nouryokusha Battle (English).gba"

cp "$INPUT_ROM" "$OUTPUT_ROM"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM" --ascii-mode --ascii-newline=0x0A

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"
