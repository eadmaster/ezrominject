import os

# Configuration
BIOS_PATH = "SCPH1001.BIN"
FONT_PATH = "font8x16.bin"  # Assuming 8x16 source to be cropped/fitted
OUTPUT_PATH = "SCPH1001_patched.BIN"

# PS1 Font Constants (Shift-JIS block)
BIOS_START_OFFSET = 0x69D68  
TILE_SIZE_BYTES = 30         # 16x15 at 1bpp (15 rows * 2 bytes)
ROWS = 15                    # PS1 uses 15 rows instead of 16

# User-provided font offsets (adjust as needed for your font8x16.bin)
UPPER_A_OFFSET = 0x210
LOWER_A_OFFSET = 0x410

def get_glyph(font_data, char_code):
    """Returns 16 bytes for an 8x16 glyph from source."""
    if ord('A') <= char_code <= ord('Z'):
        offset = UPPER_A_OFFSET + (char_code - ord('A')) * 16
    elif ord('a') <= char_code <= ord('z'):
        offset = LOWER_A_OFFSET + (char_code - ord('a')) * 16
    elif char_code == ord(' '):
        return b'\x00' * 16
    else:
        return b'\x00' * 16
    
    return font_data[offset : offset + 16]

def patch_bios():
    if not os.path.exists(BIOS_PATH) or not os.path.exists(FONT_PATH):
        print("Error: Files missing.")
        return

    with open(BIOS_PATH, "rb") as f:
        bios_data = bytearray(f.read())
    with open(FONT_PATH, "rb") as f:
        font_data = f.read()

    # Character pool
    letters = [chr(i) for i in range(ord('A'), ord('Z')+1)] + \
              [chr(i) for i in range(ord('a'), ord('z')+1)] + \
              [" "]

    current_ptr = BIOS_START_OFFSET
    sjis_value = 0x889F

    print(f"Patching pairs into 16x15 slots starting at {hex(BIOS_START_OFFSET)}...")

    for char1 in letters:
        for char2 in letters:
            # Check if we have room for the 30-byte tile
            if current_ptr + TILE_SIZE_BYTES > len(bios_data):
                break

            glyph1 = get_glyph(font_data, ord(char1))
            glyph2 = get_glyph(font_data, ord(char2))

            # Stitching Row-by-Row (Limiting to 15 rows for PS1)
            stitched_tile = bytearray()
            for i in range(ROWS): 
                stitched_tile.append(glyph1[i]) # Left 8 bits
                stitched_tile.append(glyph2[i]) # Right 8 bits

            # Inject 30 bytes into BIOS
            bios_data[current_ptr : current_ptr + TILE_SIZE_BYTES] = stitched_tile
            
            # Advance exactly 30 bytes
            current_ptr += TILE_SIZE_BYTES
            
            # print table to stdout
            print("%X=%s%s" % (sjis_value, char1, char2))
            lead = sjis_value >> 8
            trail = sjis_value & 0xFF
            trail += 1
            if trail == 0x7F: trail = 0x80
            elif trail > 0xFC:
                trail = 0x40
                lead += 1
            sjis_value = (lead << 8) | trail

    with open(OUTPUT_PATH, "wb") as f:
        f.write(bios_data)
    
    print(f"Done! {OUTPUT_PATH} generated.")

if __name__ == "__main__":
    patch_bios()