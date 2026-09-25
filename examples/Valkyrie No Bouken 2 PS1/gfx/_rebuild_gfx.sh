
# ending  https://www.youtube.com/watch?v=I5oM_NGDFAw&t=7569s
# crystaltile VALEND_ending_part*.BIN.decomp
#   -> set: width=256, height=8, Tile form=GBA 4bpp

python _recomp.py VALEND_ending_part1_eng.BIN.decomp VALEND_ending_part1_eng.BIN.recomp
cp VALEND_ending_part1_eng.BIN.recomp  VALEND_ending_part1_eng.BIN.recomp.padded
truncate -s 12559 VALEND_ending_part1_eng.BIN.recomp.padded

python _recomp.py VALEND_ending_part2_eng.BIN.decomp VALEND_ending_part2_eng.BIN.recomp
cp VALEND_ending_part2_eng.BIN.recomp  VALEND_ending_part2_eng.BIN.recomp.padded
truncate -s 12573 VALEND_ending_part2_eng.BIN.recomp.padded

python _recomp.py VALEND_ending_part3_eng.BIN.decomp VALEND_ending_part3_eng.BIN.recomp
cp VALEND_ending_part3_eng.BIN.recomp  VALEND_ending_part3_eng.BIN.recomp.padded
truncate -s 12788 VALEND_ending_part3_eng.BIN.recomp.padded

python _recomp.py VALEND_ending_part4_eng.BIN.decomp VALEND_ending_part4_eng.BIN.recomp
cp VALEND_ending_part4_eng.BIN.recomp  VALEND_ending_part4_eng.BIN.recomp.padded
truncate -s 12341 VALEND_ending_part4_eng.BIN.recomp.padded

python _recomp.py VALEND_ending_part5_eng.BIN.decomp VALEND_ending_part5_eng.BIN.recomp
cp VALEND_ending_part5_eng.BIN.recomp  VALEND_ending_part5_eng.BIN.recomp.padded
truncate -s 11032 VALEND_ending_part5_eng.BIN.recomp.padded

python _recomp.py VALEND_ending_part6_eng.BIN.decomp VALEND_ending_part6_eng.BIN.recomp
cp VALEND_ending_part6_eng.BIN.recomp  VALEND_ending_part6_eng.BIN.recomp.padded
truncate -s 3713 VALEND_ending_part6_eng.BIN.recomp.padded

python _recomp.py VALEND_ending_part6_eng.BIN.decomp VALEND_ending_part6_eng.BIN.recomp
cp VALEND_ending_part6_eng.BIN.recomp  VALEND_ending_part6_eng.BIN.recomp.padded
truncate -s 3713 VALEND_ending_part6_eng.BIN.recomp.padded


# opening
# crystaltile VALTIT2_opening_part*.BIN.decomp
#   -> set: width=256, height=8, Tile form=GBA 4bpp

python _recomp.py VALTIT2_opening_part1_eng.BIN.decomp VALTIT2_opening_part1_eng.BIN.recomp
cp VALTIT2_opening_part1_eng.BIN.recomp VALTIT2_opening_part1_eng.BIN.recomp.padded
truncate -s 10552 VALTIT2_opening_part1_eng.BIN.recomp.padded

python _recomp.py VALTIT2_opening_part2_eng.BIN.decomp VALTIT2_opening_part2_eng.BIN.recomp
cp VALTIT2_opening_part2_eng.BIN.recomp VALTIT2_opening_part2_eng.BIN.recomp.padded
truncate -s 10330 VALTIT2_opening_part2_eng.BIN.recomp.padded

python _recomp.py VALTIT2_opening_part3_eng.BIN.decomp VALTIT2_opening_part3_eng.BIN.recomp
cp VALTIT2_opening_part3_eng.BIN.recomp VALTIT2_opening_part3_eng.BIN.recomp.padded
truncate -s 5609 VALTIT2_opening_part3_eng.BIN.recomp.padded


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

