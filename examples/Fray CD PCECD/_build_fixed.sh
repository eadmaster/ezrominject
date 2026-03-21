
INPUT_ROM="In Magical Adventure - Fray CD - Xak Gaiden (Japan) (Track 02).bin"
OUTPUT_ROM="In Magical Adventure - Fray CD - Xak Gaiden (Japan) (Track 02) (patched).bin"

cp "$INPUT_ROM" "$OUTPUT_ROM"

rominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM" --ascii-bios-hack 
# NOT SUPPORTED: ascii mode
# MEMO: need to skip control code: " 娃=0x88a1"

rominject.py *_jap.txt *_eng_retrosub.txt "$OUTPUT_ROM"

#TODO: regenerate EDC/ECC data  https://github.com/alex-free/edcre/issues/5
#edcre "$OUTPUT_ROM"

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$INPUT_ROM.xdelta"
