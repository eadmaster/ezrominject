
INPUT_ROM="Simple DS Series Vol. 18 - The Soukou Kihei Gun Ground (Japan).nds"
OUTPUT_ROM="Simple DS Series Vol. 18 - The Soukou Kihei Gun Ground (English).nds"

cp "$INPUT_ROM" "$OUTPUT_ROM"

#rominject.py *_jap.txt *_eng.txt.uppercase "$OUTPUT_ROM"
rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM" --ascii-mode  --ascii-newline=0x00

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"



