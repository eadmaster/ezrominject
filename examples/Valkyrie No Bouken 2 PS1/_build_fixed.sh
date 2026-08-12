
INPUT_ROM="Namco Anthology 2 (Japan).bin"
OUTPUT_ROM="Namco Anthology 2 (Japan) (patched).bin"
EXTRACT_PATH="cd_extracted"

[ ! -d "$EXTRACT_PATH" ] && dumpsxiso -x "$EXTRACT_PATH" "$INPUT_ROM"

cd "$EXTRACT_PATH/VAL"
for f in *.*; do
    if [ -f "../../${f}_eng.txt" ]; then
        # TODO: EVNBASENAME="$(basename "$eventfile" .EVN )"
        cp "$f" ../../
        python ../../../../ezrominject.py "../../${f}_jap.txt" "../../${f}_eng.txt"  "../../$f" --ascii-bios-hack
    fi
done

cd ../..

# boot straight into the game, skip main menu
sfk replace "$EXTRACT_PATH/SYSTEM.CNF" -text '/SLPS_012.21/VAL\VAL.EXE/'  -yes

# rebuild with https://github.com/Lameguy64/mkpsxiso
mkpsxiso -y --cuefile /dev/null "Namco Anthology 2 (English).xml"

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"
