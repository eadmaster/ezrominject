
INPUT_ROM="Saiyuuki Kinkaku Ginkaku no Inbou (Japan).nds"
OUTPUT_ROM="Saiyuuki Kinkaku Ginkaku no Inbou (English).nds"

cp "$INPUT_ROM" "$OUTPUT_ROM"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM" 
#NOT SUPPORTED: --ascii-mode

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"



