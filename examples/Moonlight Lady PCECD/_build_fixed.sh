#!/bin/bash

INPUT_ROM="Moonlight Lady (Japan) (Track 02).bin"
OUTPUT_ROM="Moonlight Lady (Japan) (Track 02) (patched).bin"
 
# strip ecc data
../../bchunk-bin2iso/bchunk-bin2iso -t 00:03:00 "$INPUT_ROM" "$OUTPUT_ROM"

python ../../ezrominject.py *_jap.txt *_eng.txt "$OUTPUT_ROM" --kana-1-byte  --ascii-bios-hack 

xdelta3 -S none -f -e -s "$INPUT_ROM" "$OUTPUT_ROM"  "$INPUT_ROM.xdelta"



