
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
sfk partcopy gfx/VALOBJ00_menu3_eng.BIN.recomp.padded 0 559 VALOBJ00.BIN 0x15982 -yes
cp "$EXTRACT_PATH/VAL/VALTIT2.BIN" .
sfk partcopy gfx/VALOBJ00_menu2_eng.BIN.recomp.padded 0 7012 VALTIT2.BIN 0x5C516 -yes
# titlescreen abd cutscenes
sfk partcopy gfx/OUTTIT2_022.bin.recomp.padded 0 0x32CA VALTIT2.BIN 0x054A36 -yes
sfk partcopy gfx/OUTTIT2_023.bin.recomp.padded 0 0x488 VALTIT2.BIN 0x057D00 -yes
sfk partcopy gfx/VALTIT2_opening_part1_eng.BIN.recomp.padded 0 10552 VALTIT2.BIN 0x4E044 -yes


# rebuild with https://github.com/Lameguy64/mkpsxiso
mkpsxiso -y --cuefile /dev/null "Namco Anthology 2 (English).xml"

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$OUTPUT_ROM.xdelta"
