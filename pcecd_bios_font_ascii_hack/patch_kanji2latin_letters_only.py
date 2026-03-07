import os

# Configuration
BIOS_PATH = "syscard3.pce"
FONT_PATH = "font8x16.bin"
OUTPUT_PATH = "syscard3_patched.bin"
import os


# User-provided offsets
BIOS_START_OFFSET = 0x138A2  # Starting at 0x889F (亜)
UPPER_A_OFFSET = 0x210       # 'A'
LOWER_A_OFFSET = 0x410       # 'a'
TILE_SIZE_BYTES = 32         # 16x16 at 1bpp

def get_glyph(font_data, char_code):
    """Calculates the offset and returns 16 bytes for an 8x16 glyph."""
    if ord('A') <= char_code <= ord('Z'):
        offset = UPPER_A_OFFSET + (char_code - ord('A')) * 16
    elif ord('a') <= char_code <= ord('z'):
        offset = LOWER_A_OFFSET + (char_code - ord('a')) * 16
    else:
        # Fallback to a space or null if character is out of range
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

    # We'll create a list of all letters to iterate through
    letters = [chr(i) for i in range(ord('A'), ord('Z')+1)] + \
              [chr(i) for i in range(ord('a'), ord('z')+1)] + \
              [" "]

    current_ptr = BIOS_START_OFFSET
    sjis_value = 0x889F          # encoding value

    print(f"Patching {len(letters)**2} combinations starting at {hex(BIOS_START_OFFSET)}...")

    for char1 in letters:
        for char2 in letters:
            glyph1 = get_glyph(font_data, ord(char1))
            glyph2 = get_glyph(font_data, ord(char2))

            # Stitching Row-by-Row
            stitched_tile = bytearray()
            for i in range(16):
                stitched_tile.append(glyph1[i]) # Left half
                stitched_tile.append(glyph2[i]) # Right half

            # Inject into BIOS
            if current_ptr + TILE_SIZE_BYTES <= len(bios_data):
                bios_data[current_ptr : current_ptr + TILE_SIZE_BYTES] = stitched_tile
                current_ptr += TILE_SIZE_BYTES
            else:
                print("Warning: Reached end of BIOS file before finishing all pairs.")
                break
            
            # print table to stdout
            print("%X=%s%s" % (sjis_value, char1, char2))
            lead = sjis_value >> 8
            trail = sjis_value & 0xFF
            trail += 1
            # Skip the 0x7F control code gap
            if trail == 0x7F:
                trail = 0x80
            # Roll over to the next lead byte row when we pass 0xFC
            elif trail > 0xFC:
                trail = 0x40
                lead += 1
            sjis_value = (lead << 8) | trail  # Recombine the bytes back into the integer

    with open(OUTPUT_PATH, "wb") as f:
        f.write(bios_data)
    
    print(f"Done! Created {OUTPUT_PATH}")

if __name__ == "__main__":
    patch_bios()