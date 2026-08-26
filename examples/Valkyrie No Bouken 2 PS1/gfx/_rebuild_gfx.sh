# crystaltile VALTIT2_opening_part1.BIN.decomp
#   -> set: width=256, height=8, Tile form=GBA 4bpp

python _recomp.py VALTIT2_opening_part1_eng.BIN.decomp VALTIT2_opening_part1_eng.BIN.recomp
cp VALTIT2_opening_part1_eng.BIN.recomp VALTIT2_opening_part1_eng.BIN.recomp.padded
truncate -s 10552 VALTIT2_opening_part1_eng.BIN.recomp.padded


# titlescreen
python _recomp.py OUTTIT2_022.bin.decomp OUTTIT2_022.bin.recomp
cp OUTTIT2_022.bin.recomp OUTTIT2_022.bin.recomp.padded
truncate -s 13002 OUTTIT2_022.bin.recomp.padded

python _recomp.py OUTTIT2_023.bin.decomp OUTTIT2_023.bin.recomp
cp OUTTIT2_023.bin.recomp OUTTIT2_023.bin.recomp.padded
truncate -s 1160 OUTTIT2_023.bin.recomp.padded

# crystaltile VALOBJ00.BIN_menu_eng.decomp
#   -> set: width=228, height=8, Tile form=GBA 4bpp

python _recomp.py VALOBJ00.BIN_menu_eng.BIN.decomp VALOBJ00_menu_eng.BIN.recomp
cp VALOBJ00_menu_eng.BIN.recomp VALOBJ00_menu_eng.BIN.recomp.padded
truncate -s 13947 VALOBJ00_menu_eng.BIN.recomp.padded


# crystaltile VALOBJ00.BIN_menu2_eng.decomp
#   -> set: width=252, height=8, Tile form=GBA 4bpp

python _recomp.py VALOBJ00_menu2_eng.BIN.decomp VALOBJ00_menu2_eng.BIN.recomp
cp VALOBJ00_menu2_eng.BIN.recomp VALOBJ00_menu2_eng.BIN.recomp.padded
truncate -s 7012 VALOBJ00_menu2_eng.BIN.recomp.padded


# crystaltile VALOBJ00.BIN_menu3_eng.decomp
#   -> set: width=104, height=8, Tile form=GBA 4bpp

python _recomp.py VALOBJ00_menu3_eng.BIN.decomp VALOBJ00_menu3_eng.BIN.recomp
cp VALOBJ00_menu3_eng.BIN.recomp VALOBJ00_menu3_eng.BIN.recomp.padded
truncate -s 559 VALOBJ00_menu3_eng.BIN.recomp.padded

