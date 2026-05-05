
INPUT_ROM="Kaisoku Tenshi - The Rapid Angel (Japan) (Track 1).bin"
OUTPUT_ROM="Kaisoku Tenshi - The Rapid Angel (Japan) (Track 1) (patched).bin"

cp "$INPUT_ROM" "$OUTPUT_ROM"

python ../../ezrominject.py *_jap.txt *_eng_scenes.txt "$OUTPUT_ROM"  # cutscenes using internal font
python ../../ezrominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM" --ascii-bios-hack  # dialogues using bios font
#NOT COMPAT:  --ascii-mode
 
xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"



