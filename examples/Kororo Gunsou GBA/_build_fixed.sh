
INPUT_ROM="Keroro Gunsou - Taiketsu! Gekisou Keronprix Daisakusen de Arimasu!! (Japan).gba"
OUTPUT_ROM="Keroro Gunsou - Taiketsu! Gekisou Keronprix Daisakusen de Arimasu!! (English).gba"

cp "$INPUT_ROM" "$OUTPUT_ROM"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM"
# --abbreviate

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"



