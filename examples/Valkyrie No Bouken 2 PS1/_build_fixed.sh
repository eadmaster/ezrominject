
INPUT_ROM="Namco Anthology 2 (Japan).bin"
OUTPUT_ROM="Namco Anthology 2 (Japan) (patched).bin"
EXTRACT_PATH="cd_extracted"

[ ! -d "$EXTRACT_PATH" ] && dumpsxiso -x "$EXTRACT_PATH" "$INPUT_ROM"
[ ! -d "$EXTRACT_PATH" ] && exit 1

for f in *_eng.txt; do
    BASENAME="$(basename "$f" _eng.txt )"
    cp "$EXTRACT_PATH/VAL/$BASENAME" .
    python ../../ezrominject.py "${BASENAME}_jap.txt" "${BASENAME}_eng.txt"  "$BASENAME" --ascii-bios-hack
done

# boot straight into the game, skip main menu
sfk replace "$EXTRACT_PATH/SYSTEM.CNF" -text '/SLPS_012.21/VAL\VAL.EXE/'  -yes

# patch gfx
cp "$EXTRACT_PATH/VAL/VALOBJ00.BIN" .
sfk partcopy gfx/VALOBJ00_menu_eng.BIN.recomp.padded 0 13947 VALOBJ00.BIN 0x3288 -yes
sfk partcopy gfx/VALOBJ00_menu2_eng.BIN.recomp.padded 0 7012 VALOBJ00.BIN 0x1724 -yes

# rebuild with https://github.com/Lameguy64/mkpsxiso
mkpsxiso -y --cuefile /dev/null "Namco Anthology 2 (English).xml"

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"
