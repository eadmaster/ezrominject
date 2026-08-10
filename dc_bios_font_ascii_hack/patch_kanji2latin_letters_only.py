import os
import itertools

# --- Configuration ---
BIOS_PATH = "dc_boot.bin"
OUTPUT_PATH = "dc_boot_patched.bin"
FONT_PATH = "spleen-12x24.psfu"

# --- Constants ---
BIOS_START_OFFSET = 0x10e1b0
ROWS = 24
TILE_SIZE_BYTES = 72        # DC Kanji is 24x24 at 1bpp (3 bytes/row * 24 rows)
GLYPH_BYTES = 48            # 12x24 font takes 2 bytes/row in standard PSFU

# User-provided font offsets
UPPER_A_OFFSET = 0xc50
LOWER_A_OFFSET = 0x1250


def get_glyph(font_data, char_code):
    """Returns 48 bytes (2 bytes * 24 rows) for a 12x24 glyph from the PSFU."""
    if ord('A') <= char_code <= ord('Z'):
        offset = UPPER_A_OFFSET + (char_code - ord('A')) * GLYPH_BYTES
    elif ord('a') <= char_code <= ord('z'):
        offset = LOWER_A_OFFSET + (char_code - ord('a')) * GLYPH_BYTES
    else: 
        # Default to blank space for unmapped characters
        return b'\x00' * GLYPH_BYTES
    
    return font_data[offset : offset + GLYPH_BYTES]


def sjis_generator(start_value=0x889F):
    """Generator that yields sequential, valid Shift-JIS byte combinations."""
    sjis_value = start_value
    while True:
        yield sjis_value
        lead = sjis_value >> 8
        trail = sjis_value & 0xFF
        trail += 1
        
        if trail == 0x7F:
            trail = 0x80
        elif trail > 0xFC:
            trail = 0x40
            lead += 1
            
        sjis_value = (lead << 8) | trail


def patch_bios():
    if not os.path.exists(BIOS_PATH) or not os.path.exists(FONT_PATH):
        print("Error: Target files missing in the current directory.")
        return

    with open(BIOS_PATH, "rb") as f:
        bios_data = bytearray(f.read())
        
    with open(FONT_PATH, "rb") as f:
        font_data = f.read()

    # Create character pool: A-Z, a-z, and Space
    letters = [chr(i) for i in range(ord('A'), ord('Z') + 1)] + \
              [chr(i) for i in range(ord('a'), ord('z') + 1)] + \
              [" "]

    current_ptr = BIOS_START_OFFSET
    sjis_gen = sjis_generator()

    print(f"Patching 24x24 bigrams starting at {hex(BIOS_START_OFFSET)}...")

    # itertools.product cleanly generates all 2-character permutations (e.g., AA, AB... z ,  )
    for char1, char2 in itertools.product(letters, repeat=2):
        
        # Prevent overflowing the BIOS boundaries
        if current_ptr + TILE_SIZE_BYTES > len(bios_data):
            print("Warning: Reached end of BIOS file space. Stopping.")
            break

        glyph1 = get_glyph(font_data, ord(char1))
        glyph2 = get_glyph(font_data, ord(char2))

        stitched_tile = bytearray()
        
        # Stitch Row-by-Row
        for row in range(ROWS): 
            # Read 2 bytes (16 bits) for each character's current row
            row_l_bytes = glyph1[row*2 : row*2 + 2]
            row_r_bytes = glyph2[row*2 : row*2 + 2]
            
            # Convert bytes to integer
            val_l = int.from_bytes(row_l_bytes, 'big')
            val_r = int.from_bytes(row_r_bytes, 'big')
            
            # PSFU 12-pixel data is left-aligned in the 16 bits. Extract the top 12.
            pixels_l = val_l >> 4
            pixels_r = val_r >> 4
            
            # Bitwise OR them together: 12 bits left + 12 bits right = 24 bits (3 bytes)
            combined_24bit = (pixels_l << 12) | pixels_r
            
            # Append the calculated 3 bytes to our tile
            stitched_tile.extend(combined_24bit.to_bytes(3, 'big'))

        # Inject the newly formed 72-byte block into the BIOS
        bios_data[current_ptr : current_ptr + TILE_SIZE_BYTES] = stitched_tile
        current_ptr += TILE_SIZE_BYTES
        
        # Print mapping table output
        sjis_value = next(sjis_gen)
        print(f"{sjis_value:X}={char1}{char2}")

    with open(OUTPUT_PATH, "wb") as f:
        f.write(bios_data)
    
    print(f"\nSuccess! Patched BIOS saved to: {OUTPUT_PATH}")


if __name__ == "__main__":
    patch_bios()